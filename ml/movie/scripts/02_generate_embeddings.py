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

    # 임베딩 모델 로드
    print("모델 로딩 중...")
    model = SentenceTransformer('jhgan/ko-sroberta-multitask')

    # 임베딩 생성
    texts = [ep['text_for_embedding'] for ep in episodes]
    print(f"{len(texts)}개 텍스트 임베딩 생성 중...")
    embeddings = model.encode(texts, show_progress_bar=True)

    # 저장
    output_path = f"{data_dir}/embeddings.npy"
    np.save(output_path, embeddings)

    print(f"임베딩 shape: {embeddings.shape}")
    print(f"저장: {output_path}")


if __name__ == "__main__":
    main()