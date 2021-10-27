# -*- coding: utf-8 -*-
"""
Created on Tue Oct 26 18:14:50 2021

@author: ataky
"""

# Import modules.

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output

import pandas as pd
import plotly.graph_objs as go

# Query to count trees per each unique combination of borough, health, stewardship, and species.
# Then, there will be 4,565 results, but limited to 1,000 results at a time. So read in pages 1-5 to get everything.

soql_url = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' + \
            '$select=spc_common,boroname,health,steward,count(tree_id)' + \
            '&$group=spc_common,boroname,health,steward').replace(' ', '%20')

pg1 = pd.read_json(soql_url)
pg2 = pd.read_json(soql_url + '&$offset=1000')
pg3 = pd.read_json(soql_url + '&$offset=2000')
pg4 = pd.read_json(soql_url + '&$offset=3000')
pg5 = pd.read_json(soql_url + '&$offset=4000')

counts = pd.concat([pg1, pg2, pg3, pg4, pg5])

counts = counts.dropna()  # Drop rows missing information.


# From Dash documentation.

def generate_table(dataframe, max_rows=counts.shape[0] + 1):
    return html.Table(
        
        [html.Tr([html.Th(col) for col in dataframe.columns])] +

        
        [html.Tr([
            html.Td(dataframe.iloc[i][col]) for col in dataframe.columns
        ]) for i in range(min(len(dataframe), max_rows))]
    )


external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
server = app.server

colors = {'background': 'blue', 'text': 'red'}

app.layout = html.Div( children=[
    html.H2(children='Tree Species Health in NYC', style={'textAlign':'center', 'color':colors['text']}),
    html.H6(children='Study based on 2015 street tree census data', style={'textAlign':'center', 'color':colors['text']}),
    html.H6(children='Tree Species'),
    dcc.Dropdown(id='species', options=[
        {'label': i, 'value': i} for i in counts.spc_common.unique()
    ], value='London planetree', multi=False, placeholder='Filter by species.'),
    html.H6(children='Borough'),
    dcc.Dropdown(id='borough', options=[
        {'label': j, 'value': j} for j in counts.boroname.unique()
    ], value='Queens', multi=False, placeholder='Filter by borough.'),
    html.Div(id='table-container'),
    html.H4(children='1. Health distribution of tree species per Borough', style={'color':'blue'}), 
    dcc.Graph(id='health-dist'),
    html.H4(children='2. Stewards activity & Tree Health distribution', style={'color':'blue'}),
    dcc.Graph(id='health-vs-steward')
])


@app.callback(
    dash.dependencies.Output('health-dist', 'figure'),
    [dash.dependencies.Input('species', 'value'),
     dash.dependencies.Input('borough', 'value')])
def update_graph(species_value, borough_value):
    counts_of_interest = counts[(counts['spc_common'] == species_value) & (counts['boroname'] == borough_value)]
    counts_per_health = counts_of_interest.groupby('health').sum()['count_tree_id']
    return {
        'data': [go.Bar(
            x=counts_per_health.index,
            y=counts_per_health
        )],
        'layout': go.Layout(
            xaxis=dict(title='Health'),
            yaxis=dict(title='Number of trees')
        )
    }


@app.callback(
    dash.dependencies.Output('health-vs-steward', 'figure'),
    [dash.dependencies.Input('species', 'value'),
     dash.dependencies.Input('borough', 'value')])
def update_graph(species_value, borough_value):
    counts_of_interest = counts[(counts['spc_common'] == species_value) & (counts['boroname'] == borough_value)]

    counts_per_steward = counts_of_interest.groupby('steward').sum()['count_tree_id']

    health_as_percent_steward = pd.merge(counts_of_interest,
                                         pd.DataFrame(counts_per_steward),
                                         on='steward')

    health_as_percent_steward['percent_steward'] = health_as_percent_steward['count_tree_id_x'] * 100 / \
                                                   health_as_percent_steward['count_tree_id_y']

    health_as_percent_steward = health_as_percent_steward.pivot(index='steward',
                                                                columns='health',
                                                                values='percent_steward')

    # Fill out the missing values

    for health in ['Poor', 'Fair', 'Good']:
        if health not in health_as_percent_steward.columns.tolist():
            health_as_percent_steward[health] = [0] * len(health_as_percent_steward.index)

    trace3 = go.Bar(
        x=health_as_percent_steward['Poor'].index,
        y=health_as_percent_steward['Poor'],
        name='Poor')

    trace2 = go.Bar(
        x=health_as_percent_steward['Fair'].index,
        y=health_as_percent_steward['Fair'],
        name='Fair')

    trace1 = go.Bar(
        x=health_as_percent_steward['Good'].index,
        y=health_as_percent_steward['Good'],
        name='Good')

    return {
        'data': [trace1, trace2, trace3],
        'layout': go.Layout(
            xaxis=dict(title='Number of stewards'),
            yaxis=dict(title='Percent of trees'),
            barmode='stack'
        )
    }


if __name__ == '__main__':
    app.run_server(debug=True)