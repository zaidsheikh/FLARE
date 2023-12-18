#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Translate XLSUM burmese data to english using "orgcatorg/nllb-200-distilled-600M-my"
"""

import json
import re
from transformers import pipeline
from torch.utils.data import Dataset
from tqdm import tqdm
import string
import argparse


class ListDataset(Dataset):
    def __init__(self, original_list):
        self.original_list = original_list

    def __len__(self):
        return len(self.original_list)

    def __getitem__(self, i):
        return self.original_list[i]


def translate_xlsum(input_jsonl, output_jsonl, batch_size=10):
    # max_len = translator.model.config.max_length
    with open(input_jsonl, "r") as fin:
        data = fin.readlines()
        data = [json.loads(line) for line in data]
        sents_my = []
        for json_data in data:
            for key in ["title", "summary", "text"]:
                json_data[key] = [
                    x for x in re.split("။|၏", json_data[key]) if x.strip() != ""
                ]
                sents_my += json_data[key]
        print(f"Total number of sentences: {len(sents_my)}")

        # converting to torch Dataset allows us to use tqdm
        sents_my_dataset = ListDataset(sents_my)
        sents_en = list(
            tqdm(
                translator(
                    sents_my_dataset,
                    src_lang="mya_Mymr",
                    tgt_lang="eng_Latn",
                    batch_size=batch_size,
                ),
                total=len(sents_my_dataset),
            )
        )

        assert len(sents_my) == len(sents_en)
        assert all([isinstance(s, list) for s in sents_en])
        assert all([len(s) == 1 for s in sents_en])
        assert all(["translation_text" in s[0] for s in sents_en])
        assert all([isinstance(s[0]["translation_text"], str) for s in sents_en])

        sents_en = [s[0]["translation_text"].strip() for s in sents_en]
        sents_en = [
            s if s == "" or s[-1] in string.punctuation else s + "." for s in sents_en
        ]
        my2en = dict(zip(sents_my, sents_en))
        with open(output_jsonl, "w") as fout:
            for json_data in data:
                for key in ["title", "summary", "text"]:
                    json_data[key] = " ".join([my2en[s] for s in json_data[key]])
                json_data["title"] = json_data["title"].rstrip(".")
                fout.write(json.dumps(json_data) + "\n")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_jsonl", help="input jsonl file", type=str, required=True
    )
    parser.add_argument(
        "--output_jsonl", help="output jsonl file", type=str, required=True
    )
    parser.add_argument("--cuda_device", help="cuda device", type=int, default=0)
    parser.add_argument("--batch_size", help="batch size", type=int, default=10)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    translator = pipeline(
        "translation_my_to_en",
        model="orgcatorg/nllb-200-distilled-600M-my",
        device=args.cuda_device,
    )
    translate_xlsum(args.input_jsonl, args.output_jsonl, batch_size=args.batch_size)