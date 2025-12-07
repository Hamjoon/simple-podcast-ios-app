import argparse
import requests
import xml.etree.ElementTree as ET
import json
import re
import os

# 팟캐스트별 RSS URL 설정
RSS_URLS = {
    'filmclub': 'https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml',
    # 추후 다른 영화 팟캐스트 추가
}


def fetch_and_parse_rss(podcast_name):
    url = RSS_URLS[podcast_name]
    response = requests.get(url)
    response.encoding = 'utf-8'

    root = ET.fromstring(response.content)
    episodes = []

    for item in root.findall('.//item'):
        title = item.find('title').text or ""
        description = item.find('description').text or ""
        guid = item.find('guid').text or ""
        pub_date = item.find('pubDate').text or ""

        # 회차 번호 추출
        episode_num_match = re.search(r'(\d+)회', title)
        episode_num = int(episode_num_match.group(1)) if episode_num_match else None

        # 영화 제목 추출
        movie_title_match = re.search(r'\d+회\s*[-–]\s*(.+)', title)
        movie_title = movie_title_match.group(1).strip() if movie_title_match else title

        episodes.append({
            'episode_num': episode_num,
            'title': title,
            'movie_title': movie_title,
            'description': description,
            'guid': guid,
            'pub_date': pub_date,
            'text_for_embedding': f"{movie_title} {description}"
        })

    return episodes


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--podcast', required=True, choices=RSS_URLS.keys())
    args = parser.parse_args()

    # 데이터 디렉토리 생성
    data_dir = f"data/{args.podcast}"
    os.makedirs(data_dir, exist_ok=True)

    # 에피소드 추출
    episodes = fetch_and_parse_rss(args.podcast)

    # 저장
    output_path = f"{data_dir}/episodes.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(episodes, f, ensure_ascii=False, indent=2)

    print(f"[{args.podcast}] {len(episodes)}개 에피소드 추출")
    print(f"저장: {output_path}")


if __name__ == "__main__":
    main()