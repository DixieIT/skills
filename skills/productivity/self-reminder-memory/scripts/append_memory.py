#!/usr/bin/env python3
from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path

WORKSPACE = Path('/home/gmasiero/.openclaw/workspace')


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument('--text', required=True)
    p.add_argument('--due', default='none')
    args = p.parse_args()

    now = datetime.now()
    date_s = now.strftime('%Y-%m-%d')
    time_s = now.strftime('%H:%M')

    mem_dir = WORKSPACE / 'memory'
    mem_dir.mkdir(parents=True, exist_ok=True)
    day_file = mem_dir / f'{date_s}.md'

    line = f"- [{time_s}] Reminder: {args.text.strip()} (due: {args.due.strip() or 'none'})\n"
    with day_file.open('a', encoding='utf-8') as f:
        f.write(line)

    print(str(day_file))
    print(line.strip())


if __name__ == '__main__':
    main()
