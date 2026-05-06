# README

# OsanpoRecord_2025
Walking / jogging diary application built with Ruby on Rails.

## Production URL
- https://osanpo.john-watanabe.com/tweets

## Features
- User authentication (Devise)
- Create walking / jogging records
- Attach multiple images to a post (ActiveStorage)
- Category / duration / intensity / rating using ActiveHash
- Calendar-based activity date

## Tech Stack
- Ruby: 3.2.0
- Rails: 7.1.6
- Database: MySQL
- Authentication: Devise
- Storage: Amazon S3 (ActiveStorage)
- Web Server: Nginx
- App Server: Puma (systemd)
- OS: Amazon Linux 2 (AWS EC2)

## Architecture (Production)

Client (Browser)  
→ Nginx (HTTPS / Reverse Proxy)  
→ Puma (127.0.0.1:3000)  
→ Rails Application  
→ MySQL  

Rails (ActiveStorage)  
→ Amazon S3  
(bucket: `osanporecord-2025-images`)

## Local Setup

```bash
git clone git@github.com:John-Willy-Brandt/OsanpoRecord_2025.git
cd OsanpoRecord_2025
bundle install
rails db:create db:migrate
rails s

## Operations (EC2)
ssh -i ~/.ssh/osanpo-rescue ec2-user@13.159.59.87

### Puma
```bash
sudo systemctl status puma
sudo systemctl restart puma
sudo journalctl -u puma -n 100 -o cat

### Nginx

sudo systemctl status nginx
sudo systemctl restart nginx
sudo nginx -t

### Database / SQL Structure
Database Engine

This application uses different database engines by environment, which is a common 
 and practical production setup.

| Environment | Database                        |
| ----------- | ------------------------------- |
| Development | MySQL                           |
| Test        | MySQL                           |
| Production  | PostgreSQL (via `DATABASE_URL`) |


## Troubleshooting

- 502 Bad Gateway  
  → Puma stopped / Nginx proxy mismatch

- 500 unable to sign request without credentials  
  → AWS_ACCESS_KEY_ID / SECRET missing

- Blocked hosts error  
  → Add domain to production.rb

- server.pid exists  
  → Remove tmp/pids/server.pid

## ER Diagram

```mermaid
erDiagram
  users ||--o{ tweets : has_many
  users ||--o{ comments : has_many
  tweets ||--o{ comments : has_many

  users {
    bigint id PK
    string email
    string encrypted_password
    string nickname
    string family_name
    string first_name
    string family_name_kana
    string first_name_kana
    date birthday
    datetime created_at
    datetime updated_at
  }

  tweets {
    bigint id PK
    string subject
    date activity_date
    int category_id
    int duration_id
    int intensity_id
    int rating_id
    text memo
    text text
    bigint user_id FK
    datetime created_at
    datetime updated_at
  }

  comments {
    bigint id PK
    int user_id FK
    int tweet_id FK
    text text
    datetime created_at
    datetime updated_at
  }

  %% ActiveStorage (images)
  tweets ||--o{ active_storage_attachments : images
  active_storage_blobs ||--o{ active_storage_attachments : blob
  active_storage_blobs ||--o{ active_storage_variant_records : variants

  active_storage_attachments {
    string name
    string record_type
    bigint record_id
    bigint blob_id FK
    datetime created_at
  }

  active_storage_blobs {
    string key
    string filename
    string content_type
    text metadata
    string service_name
    bigint byte_size
    string checksum
    datetime created_at
  }

  active_storage_variant_records {
    bigint blob_id FK
    string variation_digest
  }

* Database creation

# Table
## Table: users
| Column             | Type   | Options     |
| ------------------ | ------ | ----------- |
| nickname           | string | null: false |
| email              | string | null: false, unique: true |
| encrypted_password | string | null: false |
| family_name        | string | null: false |
| first_name         | string | null: false |
| family_name_kana   | string | null: false |
| first_name_kana    | string | null: false |
| birthday           | date   | null: false |

class User < ApplicationRecord
  has_many :tweets, dependent: :destroy
  has_many :comments, dependent: :destroy
end

## Table: tweets

| Column        | Type       | Options                        |
| ------------- | ---------- | ------------------------------ |
| subject       | string     | null: false                    | # タイトル
| text          | text       | null: false                    | # 本文
| category_id   | integer    | null: false                    | # ランニング / 散歩 / ジョギング (ActiveHash)
| duration_id   | integer    | null: false                    | # 〜30分, 30〜60分, 60分以上... など ActiveHash
| intensity_id  | integer    | null: false                    | # （任意）強度：ゆっくり / 普通 / きつい
| rating_id     | integer    | null: false                    | # （任意）気分：最高 / 普通 / イマイチ など
| activity_date | date       | null: false                    | # カレンダーの日付
| user          | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- has_many_attached :images  # 「some images」に対応
- has_many :comments, dependent: :destroy## Table: comments

## Table: comments

| Column | Type       | Options                         |
| ------ | ---------- | ------------------------------- |
| user   | references | null: false, foreign_key: true |
| tweet  | references | null: false, foreign_key: true |
| text   | text       | null: false                    |

### Association

- belongs_to :tweet
- belongs_to :user


* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
