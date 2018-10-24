#!/home/lixue/tools/miniconda2/bin/python2.7

"""
Produces a stacked bar plot showing the ranking and quality of the
models of a particular run.

Expects __at least__ a two-column file with RMSD values in the first
column and Energy values on the second. This has to be provided via the
--columns option.

The models are sorted by energy values (lowest on the bar are the best scoring,
i.e. most negative energy).

Color coding of the bars can be changed in the script header. Default, red/orange/blue
in increasing quality (decreasing RMSD value).

Supports multiple pairs of columns (--columns 1 2 --columns 3 4) to plot
several bars in the same plot.

Example:

python make_ranking-plot.py results_all_1nq7_r2 --columns 3 2 --output bar.eps

python make_ranking-plot.py results_all_1nq7_r2 --columns 3 2 --columns 8 5 --columns 9 6 --columns 10 7
"""

from __future__ import print_function

import operator
import os
import sys

try:
    import numpy as np
except ImportError as err:
    print("[!] Could not import numpy:\n{0}".format(err), file=sys.stderr)
    sys.exit(1)

try:
    import matplotlib
    matplotlib.use('Agg') # For cluster
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
except ImportError as err:
    print("[!] Could not import matplotlib:\n{0}".format(err), file=sys.stderr)
    sys.exit(1)

#
# Color coding per RMSD value
#
def _color_code(value):
#    if 0 <= value <= 2:
#        return 'deepskyblue'
#    elif 2 < value <= 5:
#        return 'orange'
#    elif 5 < value <= 10:
#        return 'red'
#    else:
#	return 'gray'

    if 0 <= value <= 4:
        return 'deepskyblue'
#    elif 2 < value <= 5:
#        return 'orange'
#    elif 5 < value <= 10:
#        return 'red'
    else:
       return 'gray'

# Have to make a proxy artist for every color..
#legend_data = [ (plt.Rectangle((0, 0), 1, 1, fc="deepskyblue"), r'l-RMSD <= 2$\AA$'),
#                (plt.Rectangle((0, 0), 1, 1, fc="orange"), r'2$\AA$ < l-RMSD <= 5$\AA$'),
#                (plt.Rectangle((0, 0), 1, 1, fc="red"), r'5$\AA$ < l-RMSD <= 10$\AA$'),
#                (plt.Rectangle((0, 0), 1, 1, fc="gray"), r'l-RMSD > 10$\AA$') ]

legend_data = [ (plt.Rectangle((0, 0), 1, 1, fc="deepskyblue"), r'i-RMSD <= 4$\AA$'),
#                (plt.Rectangle((0, 0), 1, 1, fc="orange"), r'2$\AA$ < l-RMSD <= 5$\AA$'),
#                (plt.Rectangle((0, 0), 1, 1, fc="red"), r'5$\AA$ < l-RMSD <= 10$\AA$'),
                (plt.Rectangle((0, 0), 1, 1, fc="gray"), r'i-RMSD > 4$\AA$') ]

legend_proxies, legend_labels = zip(*legend_data)

# Read data file
def read_data(fpath, columns):
    """
    Parses specific columns of a data file.
    """

    get_columns = lambda x,y: [float(x[i]) for i in y]

    if not os.path.isfile(fpath):
        print('[!] Input file not found: {0}'.format(fpath), file=sys.stderr)
        sys.exit(1)

    with open(fpath, 'r') as file_handle:
        data = []
        header = None

        for line in file_handle:
            line = line.strip()
            if not line:
                continue
            elif line.startswith('#'):
                if header is None:
                    # Only energy value name
                    header = line.split()[columns[1]]
            else:
                fields = line.split()
                try:
                    data.append(get_columns(fields, columns))
                except IndexError:
                    continue

    return (header, data)

if __name__ == '__main__':
    import argparse
    from argparse import RawDescriptionHelpFormatter

    ap = argparse.ArgumentParser(description=__doc__, formatter_class=RawDescriptionHelpFormatter)

    ap.add_argument('data_file', type=str, help='Input data file')
    ap.add_argument('--columns', nargs='+', action='append', required=True,
                   help='Columns (x y) to read from the file')
    ap.add_argument('-o', '--output', type=str, default='bars.eps',
                   help='Output file name for plot (extension determines format)')
    ap.add_argument('--no-sort', action='store_true',
                   help='Does not sort the initial data')
#    ap.add_argument('--title', nargs='+', type=str, action='append', required=True,
#            help='title of the figure')

    args = ap.parse_args()
#    title = args.title

    #-- tmp

    # Make plot
#   f = plt.figure()#figsize=(190/25.4, 240/25.4), dpi=300)
    f = plt.figure()#figsize=(270/25.4, 320/25.4), dpi=300)
    ax = plt.gca()

    matplotlib.rcParams.update({'font.size': 18})
    stack_h = 1
    max_stack_v = 0
    stack_h_labels = []

    for pair in args.columns:
        # Handle column numbers
        columns = map(lambda x: int(x)-1, pair)

        # Parse data file (multiple times, not ideal..)
        header, data = read_data(args.data_file, columns)
#        stack_h_labels.append(header)
        #for i in range(1,37):
        #    stack_h_labels.append('FXR_'+str(i))
        stack_h_labels = ['Haddock', 'PSSM', 'Combined']
        # Sort data by energy score
        if not args.no_sort:
            data.sort(key=operator.itemgetter(1))

        stack_v = 0
        for entry in data:
            rmsd, energy = entry
            stack_color = _color_code(rmsd)
            #series = ax.bar(stack_h, 1, bottom=stack_v, color=stack_color,
            #                width=0.5, align='center', edgecolor='none', linewidth=0)
            series = ax.bar(stack_h, 1, bottom=stack_v, color=stack_color,
                             width=1, align='center', edgecolor='none', linewidth=0)

            stack_v += 1

        max_stack_v = max(max_stack_v, stack_v)

        stack_h += 2 # Separated by an empty series

    # Aesthetics
    ax.set_xlim((0, stack_h-1)) # Centered
    ax.set_ylim((-10, max_stack_v + 10))

    ax.set_ylabel('Ranking of decoys \n(lower is better)', fontsize=20)
    #ax.set_title(os.path.basename(args.data_file))

    stack_h_labels_pos = range(1, stack_h, 2)
    ax.set_xticks(stack_h_labels_pos)
    ax.set_xticklabels(stack_h_labels, rotation=0, fontsize = 20)

    ax.xaxis.set_ticks_position('none')
#    ax.yaxis.set_ticks([])

    # Legend
    # Shrink current axis's height by 10% on the bottom
    box = ax.get_position()
    ax.set_position([box.x0, box.y0 + box.height * 0.12,
                     box.width, box.height * 0.82])

    # Put a legend below current axis
#    ax.legend(legend_proxies, legend_labels,
#              loc='upper center', bbox_to_anchor=(0.5, -0.05), ncol=2,
#              fontsize='small')
    ax.legend(legend_proxies, legend_labels,
              loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=2,
              fontsize='small')
    # Save figure
    #plt.savefig(args.output, format='eps')
    plt.savefig(args.output, format='png', dpi=600)
