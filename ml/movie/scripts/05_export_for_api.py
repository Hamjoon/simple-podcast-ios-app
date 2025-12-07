import argparse
import json


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--podcast', required=True)
    args = parser.parse_args()

    data_dir = f"data/{args.podcast}"

    with open(f"{data_dir}/labeled.json", 'r', encoding='utf-8') as f:
        episodes = json.load(f)

    # 카테고리별 그룹화
    categories = {}
    for ep in episodes:
        label = ep['cluster_label']
        if label not in categories:
            categories[label] = {
                'label': label,
                'cluster_id': ep['cluster_id'],
                'episodes': []
            }
        categories[label]['episodes'].append({
            'episode_num': ep['episode_num'],
            'title': ep['title'],
            'movie_title': ep['movie_title'],
            'description': ep['description'],
            'guid': ep['guid']
        })

    api_output = {
        'podcast': args.podcast,
        'total_episodes': len(episodes),
        'categories': list(categories.values())
    }

    output_path = f"{data_dir}/api_output.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(api_output, f, ensure_ascii=False, indent=2)

    print(f"API 출력: {output_path}")
    print(f"총 {len(categories)}개 카테고리")


if __name__ == "__main__":
    main()