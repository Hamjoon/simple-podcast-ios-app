# scripts/02_generate_embeddings.py 버전

import argparse
import json
import numpy as np
from sentence_transformers import SentenceTransformer


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--podcast', required=True)
    args = parser.parse_args()

    data_dir = f"data/{args.podcast}"

    # 에피소드 로드
    with open(f"{data_dir}/episodes.json", 'r', encoding='utf-8') as f:
        episodes = json.load(f)

    # intfloat/multilingual-e5-large 모델 로드
    print("모델 로딩 중...")
    model = SentenceTransformer('intfloat/multilingual-e5-large')

    # E5 모델용 prefix 추가
    texts = [f"passage: {ep['text_for_embedding']}" for ep in episodes]

    print(f"{len(texts)}개 텍스트 임베딩 생성 중...")
    embeddings = model.encode(texts, show_progress_bar=True)

    # 저장
    np.save(f"{data_dir}/embeddings.npy", embeddings)

    print(f"임베딩 shape: {embeddings.shape}")
    print(f"저장: {data_dir}/embeddings.npy")


if __name__ == "__main__":
    main()