import argparse
import json

# 팟캐스트별 클러스터 라벨 설정
CLUSTER_LABELS = {
    'filmclub': {
        # 03 스크립트 결과를 보고 작성
        0: "한국영화",
        1: "애니메이션/가족",
        2: "할리우드 블록버스터",
        # ... 추가
    },
    # 추후 다른 팟캐스트 라벨 추가
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--podcast', required=True)
    args = parser.parse_args()

    data_dir = f"data/{args.podcast}"
    labels = CLUSTER_LABELS.get(args.podcast, {})

    with open(f"{data_dir}/clustered.json", 'r', encoding='utf-8') as f:
        episodes = json.load(f)

    for ep in episodes:
        cluster_id = ep['cluster_id']
        ep['cluster_label'] = labels.get(cluster_id, f"카테고리 {cluster_id}")

    output_path = f"{data_dir}/labeled.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(episodes, f, ensure_ascii=False, indent=2)

    # 통계 출력
    print("=== 카테고리별 에피소드 수 ===")
    label_counts = {}
    for ep in episodes:
        label = ep['cluster_label']
        label_counts[label] = label_counts.get(label, 0) + 1

    for label, count in sorted(label_counts.items(), key=lambda x: -x[1]):
        print(f"  {label}: {count}개")

    print(f"\n저장: {output_path}")


if __name__ == "__main__":
    main()