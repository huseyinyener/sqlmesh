import os
import time
from git import Repo
import schedule

# Git deposunun yolu (local)
REPO_PATH = "../app"

# Git URL (SSH kullanıyorsanız)
REMOTE_URL = "git@github.com:huseyinyener/sqlmesh.git"

# Branch adı
BRANCH = "main"

def git_pull():
    try:
        print("Checking for updates...")
        # Repo nesnesini yükle
        repo = Repo(REPO_PATH)

        # Güncel değişiklikleri çek
        origin = repo.remotes.origin
        origin.fetch()

        # Yerel branch ile uzak branch farklıysa pull yap
        if repo.head.commit != origin.refs[BRANCH].commit:
            print("New commits detected. Pulling changes...")
            origin.pull()
            print("Repository updated.")
        else:
            print("Repository is already up-to-date.")
    except Exception as e:
        print(f"Error during Git pull: {e}")

def start_bot():
    # Schedule: Her 5 dakikada bir git_pull çalıştır
    schedule.every(1).minutes.do(git_pull)

    print("Git Sync Bot is running... Press Ctrl+C to stop.")
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    # Eğer local repo yoksa klonla
    if not os.path.exists(REPO_PATH):
        print(f"Cloning repository to {REPO_PATH}...")
        Repo.clone_from(REMOTE_URL, REPO_PATH, branch=BRANCH)
    # Botu başlat
    start_bot()
