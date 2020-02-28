"""
Generates scatterplot of any 2-dimentional data.
TODO:
- use pass data through sys args
- use argparse to determine data format (pickle, dataframe, np array, Collection, etc.)
"""

import plotly.express as px
import pandas as pd

def generate_scatterplot(df):
    print("Generating scatterplot for data:")
    print(df)

    fig = px.scatter(df, x=columns[0], y=columns[1])
    fig.show()


def main(data, columns):
    df = pd.DataFrame.from_dict(data, orient='index', columns=columns)
    generate_scatterplot(df)

if __name__ == '__main__':
    COLUMNS = ['length', 'time']
    DATA = {
        0:[15,0.04],
        1:[16,0.08],
        2:[17,0.14],
        3:[18,0.41],
        4:[19,0.77],
        5:[20,1.36],
        6:[21,3.28],
        7:[22,6.42],
        8:[23,10.83],
        9:[24,21.15],
        10:[25,39.99],
    }

    main(DATA, COLUMNS)