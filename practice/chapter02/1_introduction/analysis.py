#!/usr/bin/env python3
"""
Simple heatmap visualization for gene expression data
Demonstrates reproducible visualization in Nix environment
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def load_data(csv_file="example.csv"):
    """Load gene expression data"""
    try:
        df = pd.read_csv(csv_file)
        # Set gene names as index
        df = df.set_index("Gene")
        print("Data loaded successfully")
        print(f"Shape: {df.shape}")
        print(f"Genes: {list(df.index)}")
        print(f"Conditions: {list(df.columns)}")
        return df
    except FileNotFoundError:
        print(f"Error: '{csv_file}' file not found")
        return None
    except Exception as e:
        print(f"Data loading error: {e}")
        return None


def create_heatmap(df):
    """Create a simple heatmap visualization"""
    if df is None:
        return

    # Create figure and axis
    fig, ax = plt.subplots(figsize=(10, 6))

    # Create heatmap using imshow
    im = ax.imshow(df.values, cmap="viridis", aspect="auto")

    # Set ticks and labels
    ax.set_xticks(np.arange(len(df.columns)))
    ax.set_yticks(np.arange(len(df.index)))
    ax.set_xticklabels(df.columns)
    ax.set_yticklabels(df.index)

    # Rotate x-axis labels for better readability
    plt.setp(ax.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")

    # Add colorbar (legend)
    cbar = ax.figure.colorbar(im, ax=ax)
    cbar.ax.set_ylabel("Expression Level", rotation=-90, va="bottom")

    # Add title and labels
    ax.set_title("Gene Expression Heatmap")
    ax.set_xlabel("Experimental Conditions")
    ax.set_ylabel("Genes")

    # Add text annotations on each cell
    for i in range(len(df.index)):
        for j in range(len(df.columns)):
            text = ax.text(
                j,
                i,
                f"{df.iloc[i, j]:.1f}",
                ha="center",
                va="center",
                color="white",
                fontsize=8,
            )

    # Adjust layout to prevent label cutoff
    fig.tight_layout()

    # Save the plot
    plt.savefig("gene_expression_heatmap.png", dpi=300, bbox_inches="tight")
    print("Heatmap saved as 'gene_expression_heatmap.png'")

    # Optional: display plot (uncomment if running interactively)
    # plt.show()


def analyze_data(df):
    """Perform basic analysis on the data"""
    if df is None:
        return

    print("\n=== Data Analysis ===")

    # Calculate mean expression per gene
    gene_means = df.mean(axis=1).sort_values(ascending=False)
    print("Mean expression per gene (highest to lowest):")
    for gene, mean_expr in gene_means.items():
        print(f"  {gene}: {mean_expr:.2f}")

    # Calculate mean expression per condition
    condition_means = df.mean(axis=0)
    print("\nMean expression per condition:")
    for condition, mean_expr in condition_means.items():
        print(f"  {condition}: {mean_expr:.2f}")

    # Find highest and lowest expressed combinations
    max_val = df.max().max()
    min_val = df.min().min()
    max_pos = df.stack().idxmax()
    min_pos = df.stack().idxmin()

    print(f"\nHighest expression: {max_val:.1f} ({max_pos[0]} in {max_pos[1]})")
    print(f"Lowest expression: {min_val:.1f} ({min_pos[0]} in {min_pos[1]})")


def main():
    """Main function to run heatmap analysis"""
    print("Gene Expression Heatmap Analysis")
    print("=" * 40)

    # Load data
    df = load_data()

    if df is not None:
        # Analyze data
        analyze_data(df)

        # Create heatmap
        print("\n=== Creating Heatmap ===")
        create_heatmap(df)

        print("\n" + "=" * 40)
        print("Analysis complete!")
        print("Heatmap visualization created successfully in Nix environment.")
    else:
        print("Cannot proceed with analysis due to data loading error.")


if __name__ == "__main__":
    main()
