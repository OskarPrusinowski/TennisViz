import pandas as pd

def summarize_match_stats(file_path):
    df = pd.read_csv(file_path)
    summary = pd.DataFrame()
    summary['match_duration'] = df['match_duration']
    summary['total_aces'] = df['winner_aces'] + df['loser_aces']
    summary['total_break_points_saved'] = df['winner_break_points_saved'] + df['loser_break_points_saved']
    summary['total_points_won'] = df['winner_total_points_won'] + df['loser_total_points_won']
    summary['total_double_faults'] = df['winner_double_faults'] + df['loser_double_faults']
    summary['year'] = df['match_stats_url_suffix'].str.split("/").str[3]
    return summary

previous_summary = summarize_match_stats("match_stats_1991-2016.csv")
summary_2017 = summarize_match_stats("match_stats_2017.csv")

combined_summary = pd.concat([previous_summary, summary_2017], ignore_index=True)
combined_summary.to_csv("match_stats.csv", index=False)

