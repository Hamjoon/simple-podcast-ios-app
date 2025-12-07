import argparse
import json
import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt


def find_optimal_k(embeddings, k_range=range(3, 15)):
    inertias = []
    silhouette_scores = []

    for k in k_range:
        kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
        kmeans.fit(embeddings)
        inertias.append(kmeans.inertia_)
        silhouette_scores.append(silhouette_score(embeddings, kmeans.labels_))
        print(f"K={k}: Inertia={kmeans.inertia_:.2f}, Silhouette={silhouette_scores[-1]:.4f}")

    return list(k_range), inertias, silhouette_scores


def plot_k_selection(k_range, inertias, silhouette_scores, output_path):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

    ax1.plot(k_range, inertias, 'bo-')
    ax1.set_xlabel('K (클러스터 수)')
    ax1.set_ylabel('Inertia')
    ax1.set_title('엘보우 방법')

    ax2.plot(k_range, silhouette_scores, 'ro-')
    ax2.set_xlabel('K (클러스터 수)')
    ax2.set_ylabel('Silhouette Score')
    ax2.set_title('실루엣 점수')

    plt.tight_layout()
    plt.savefig(output_path)
    print(f"그래프 저장: {output_path}")


def analyze_clusters(episodes, labels, n_clusters):
    clusters = {i: [] for i in range(n_clusters)}

    for ep, label in zip(episodes, labels):
        clusters[label].append(ep)

    print("\n=== 클러스터 분석 ===\n")
    for cluster_id in range(n_clusters):
        cluster_eps = clusters[cluster_id]
        print(f"[클러스터 {cluster_id}] {len(cluster_eps)}개")
        print("-" * 40)
        for ep in cluster_eps[:5]:
            print(f"  • {ep['movie_title']}")
        if len(cluster_eps) > 5:
            print(f"  ... 외 {len(cluster_eps) - 5}개")
        print()

    return clusters


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--podcast', required=True)
    parser.add_argument('--k', type=int, default=None, help='클러스터 수 (미지정시 자동 탐색)')
    args = parser.parse_args()

    data_dir = f"data/{args.podcast}"

    # 데이터 로드
    with open(f"{data_dir}/episodes.json", 'r', encoding='utf-8') as f:
        episodes = json.load(f)
    embeddings = np.load(f"{data_dir}/embeddings.npy")

    # K 탐색 또는 지정
    if args.k is None:
        print("=== 최적 K 탐색 ===")
        k_range, inertias, scores = find_optimal_k(embeddings)
        plot_k_selection(k_range, inertias, scores, f"{data_dir}/k_selection.png")

        best_k = k_range[np.argmax(scores)]
        print(f"\n추천 K: {best_k} (실루엣 점수 기준)")
        print(f"그래프를 확인 후 --k 옵션으로 원하는 K를 지정하세요.")
        return

    # 클러스터링 수행
    print(f"K={args.k}로 클러스터링 수행...")
    kmeans = KMeans(n_clusters=args.k, random_state=42, n_init=10)
    labels = kmeans.fit_predict(embeddings)

    # 분석
    analyze_clusters(episodes, labels, args.k)

    # 결과 저장
    for i, ep in enumerate(episodes):
        ep['cluster_id'] = int(labels[i])

    output_path = f"{data_dir}/clustered.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(episodes, f, ensure_ascii=False, indent=2)

    print(f"결과 저장: {output_path}")


if __name__ == "__main__":
    main()