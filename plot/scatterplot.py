"""
Generates scatterplot of any 2-dimentional data.
TODO:
- use pass data through sys args
- use argparse to determine data format (pickle, dataframe, np array, Collection, csv, etc.)
- error handling for incorrect/insufficent args
- "has_headers" args
"""

import argparse
import plotly.express as px
import pandas as pd

def generate_scatterplot(df, x, y):
    print("Generating scatterplot for data:")
    print(df)

    fig = px.scatter(df, x=x, y=y)
    fig.show()


def main(data, x, y, data_format, from_pickle=False):
    if from_pickle:
        data = pd.read_pickle(data)

    if data_format is 'dict':
        df = pd.DataFrame.from_dict(data, orient='index', columns=[x, y])
    if data_format is 'df':
        df = data
    
    generate_scatterplot(df, x, y)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate scatterplot of 2-dimentional data.')
    parser.add_argument('path', help='path to data file')
    parser.add_argument('x', help='x-axis of data')
    parser.add_argument('y', help='y-axis of data')
    parser.add_argument(
        '--format',
        help='data format (accepts: {dict, df}).',
        default='df'
        )
    parser.add_argument(
        '--pickle',
        help='indicates data file is pickled.',
        action="store_true"
        )

    args = parser.parse_args()

    main(args.path, x=args.x, y=args.y, data_format=args.format, from_pickle=args.pickle)