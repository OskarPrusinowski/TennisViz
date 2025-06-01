#combine ranking files into a single file
import pandas as pd
import pathlib

def combine_ranking_files():
    # Define the column names according to your data structure
    columns = ["rank_date", "rank", "player", "rank_points"]  # Change as needed
    combined_df = pd.DataFrame(columns=columns)
    for i in ("_70s", "_80s", "_90s", "_00s", "_10s", "_20s"):
        file_path = pathlib.Path(f"TennisWiz/data/atp_rankings{i}.csv")
        if not file_path.exists():
            print(f"File {file_path} does not exist.")
            continue
        try:
            df = pd.read_csv(file_path, names=columns, header=None)
            if not df.empty:
                combined_df = pd.concat([combined_df, df], ignore_index=True)
            else:
                print(f"File {file_path} is empty, skipping.")
        except pd.errors.EmptyDataError:
            print(f"File {file_path} is empty or invalid, skipping.")

    combined_df.to_csv("TennisWiz/data/atp_rankings_combined.csv", index=False, encoding='utf-8')


def unique_dates():
    df = pd.read_csv("TennisWiz/data/atp_rankings_combined.csv")
    unique_dates = df['rank_date'].unique()
    #change all to string
    unique_dates = [str(date) for date in unique_dates]
    unique_dates.sort()
    #divide into year month and day (format is yyyymmdd)
    unique_dates = [f"{date[:4]}{date[4:6]}{date[6:]}" for date in unique_dates]
    with open("TennisWiz/data/unique_rank_dates.csv", "w", encoding='utf-8') as f:
        for date in unique_dates:
            f.write(f"{date}\n")
unique_dates()