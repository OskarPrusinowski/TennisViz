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
    summary['order'] = df['tourney_order']

    return summary


import pandas as pd

def preprocess_turnaments(file_path):
    df = pd.read_csv(file_path)

    clean_df = pd.DataFrame()
    clean_df['year'] = df['tourney_year']
    clean_df['order'] = df['tourney_order'] - 1
    clean_df['name'] = df['tourney_name']
    clean_df['conditions'] = df['tourney_conditions']
    clean_df['surface'] = df['tourney_surface']
    clean_df['fin_commit'] = df['tourney_fin_commit']
    clean_df['winner'] = df['singles_winner_name']
    clean_df['winner_slug'] = (
        clean_df['winner']
        .str.lower()
        .str.replace(r'\s+', '-', regex=True)
        .str.replace(r'[^\w\-]', '', regex=True)
    )

    clean_df['currency'] = clean_df['fin_commit'].str.extract(r'([€$£])')
    clean_df['amount'] = pd.to_numeric(
        clean_df['fin_commit'].str.replace(r'[€$£,]', '', regex=True),
        errors='coerce'
    )

    clean_df = clean_df.dropna(subset=['amount'])
    clean_df = clean_df[clean_df['year'] >= 1991]

    return clean_df


previous_summary = summarize_match_stats("match_stats_1991-2016.csv")
summary_2017 = summarize_match_stats("match_stats_2017.csv")

combined_summary = pd.concat([previous_summary, summary_2017], ignore_index=True)

tournaments = preprocess_turnaments("tournaments_1877-2017_UNINDEXED.csv")
tournaments.to_csv('tournaments.csv',index=False)


combined_summary.to_csv("match_stats.csv", index=False)
