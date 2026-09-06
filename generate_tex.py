import re

def convert_md_to_latex(md_text):
    latex = []
    
    # Document header
    latex.append(r"\documentclass[journal, a4paper, onecolumn, 12pt]{IEEEtran}")
    latex.append(r"\usepackage[utf8]{inputenc}")
    latex.append(r"\usepackage{longtable}")
    latex.append(r"\usepackage{booktabs}")
    latex.append(r"\usepackage[hidelinks]{hyperref}")
    latex.append(r"\usepackage{enumitem}")
    latex.append(r"\usepackage{graphicx}")
    latex.append(r"\usepackage{xcolor}")
    latex.append(r"\usepackage{listings}")
    latex.append(r"")
    latex.append(r"\title{Software Requirements Specification (SRS) \\ \Large Smart Ledger — Integrated Financial Management Platform}")
    latex.append(r"\author{\IEEEauthorblockN{Project Team}\\ \IEEEauthorblockA{\textit{Smart Ledger Project} \\ May 11, 2026}}")
    latex.append(r"")
    latex.append(r"\begin{document}")
    latex.append(r"\maketitle")
    latex.append(r"\tableofcontents")
    latex.append(r"\newpage")
    
    lines = md_text.split('\n')
    
    in_table = False
    in_code_block = False
    in_list = False
    
    for i, line in enumerate(lines):
        line = line.strip()
        
        # Skip the manual title stuff at the top since we added it to \maketitle
        if i < 7 and (line.startswith('# Software Requirements') or line.startswith('## Smart Ledger') or line.startswith('**Version:**') or line.startswith('**Date:**') or line.startswith('**Status:**')):
            continue
            
        # Code blocks
        if line.startswith('```'):
            if in_code_block:
                latex.append(r"\end{verbatim}")
                in_code_block = False
            else:
                latex.append(r"\begin{verbatim}")
                in_code_block = True
            continue
            
        if in_code_block:
            # Replace unicode box drawing characters with ascii so pdflatex doesn't drop them
            box_chars = {'┌': '+', '─': '-', '┐': '+', '│': '|', '└': '+', '┘': '+', '┬': '+', '▼': 'v', '┴': '+', '┼': '+', '├': '+', '┤': '+'}
            for k, v in box_chars.items():
                line = line.replace(k, v)
            latex.append(line)
            continue
            
        # Tables
        if line.startswith('|') and not in_table:
            in_table = True
            # Count columns
            cols = line.count('|') - 1
            if cols > 0:
                col_width = 0.95 / cols
                latex.append(r"\begin{longtable}{|" + "|".join([f"p{{{col_width:.2f}\\textwidth}}"] * cols) + "|}")
            else:
                latex.append(r"\begin{longtable}{|p{0.95\textwidth}|}")
            latex.append(r"\hline")
            
        if in_table:
            if not line.startswith('|'):
                in_table = False
                latex.append(r"\end{longtable}")
            elif '---' in line:
                latex.append(r"\hline")
                continue
            else:
                # Process row
                row_content = line.strip('|').split('|')
                # Escape characters in cells
                clean_row = []
                for cell in row_content:
                    c = cell.strip()
                    c = c.replace('&', r'\&').replace('%', r'\%').replace('$', r'\$').replace('#', r'\#').replace('_', r'\_')
                    c = re.sub(r'\*\*(.*?)\*\*', r'\\textbf{\1}', c)
                    clean_row.append(c)
                latex.append(" & ".join(clean_row) + r" \\ \hline")
            continue
            
        # Headings
        if line.startswith('# '):
            title = line[2:].replace('&', r'\&').replace('_', r'\_')
            if "Table of Contents" in title:
                continue # Skip manual TOC
            title = re.sub(r'^[\d\.]+\s*', '', title)
            latex.append(r"\section{" + title + "}")
            continue
        elif line.startswith('## '):
            title = line[3:].replace('&', r'\&').replace('_', r'\_')
            title = re.sub(r'^[\d\.]+\s*', '', title)
            latex.append(r"\subsection{" + title + "}")
            continue
        elif line.startswith('### '):
            title = line[4:].replace('&', r'\&').replace('_', r'\_')
            title = re.sub(r'^[\d\.]+\s*', '', title)
            latex.append(r"\subsubsection{" + title + "}")
            continue
            
        # Lists
        if line.startswith('- '):
            if not in_list:
                latex.append(r"\begin{itemize}[leftmargin=*]")
                in_list = True
            item_text = line[2:]
            item_text = item_text.replace('&', r'\&').replace('%', r'\%').replace('$', r'\$').replace('#', r'\#').replace('_', r'\_')
            item_text = re.sub(r'\*\*(.*?)\*\*', r'\\textbf{\1}', item_text)
            latex.append(r"\item " + item_text)
            continue
        else:
            if in_list:
                latex.append(r"\end{itemize}")
                in_list = False
                
        if not line:
            latex.append("")
            continue
            
        # Horizontal rules
        if line == '---':
            latex.append(r"\vspace{1em}\hrule\vspace{1em}")
            continue
            
        # Blockquotes
        if line.startswith('> '):
            latex.append(r"\begin{quote}")
            quote_text = line[2:].replace('&', r'\&').replace('%', r'\%').replace('$', r'\$').replace('#', r'\#').replace('_', r'\_')
            quote_text = re.sub(r'\*\*(.*?)\*\*', r'\\textbf{\1}', quote_text)
            latex.append(quote_text)
            latex.append(r"\end{quote}")
            continue
            
        # Plain text
        text = line
        text = text.replace('&', r'\&').replace('%', r'\%').replace('$', r'\$').replace('#', r'\#').replace('_', r'\_')
        text = re.sub(r'\*\*(.*?)\*\*', r'\\textbf{\1}', text)
        text = re.sub(r'\*(.*?)\*', r'\\textit{\1}', text)
        text = re.sub(r'`(.*?)`', r'\\texttt{\1}', text)
        latex.append(text)
        
    if in_list:
        latex.append(r"\end{itemize}")
    if in_table:
        latex.append(r"\end{longtable}")
        
    latex.append(r"\end{document}")
    
    return "\n".join(latex)

if __name__ == "__main__":
    with open('SRS_SmartLedger.md', 'r', encoding='utf-8') as f:
        md = f.read()
    
    tex = convert_md_to_latex(md)
    
    with open('SRS_SmartLedger.tex', 'w', encoding='utf-8') as f:
        f.write(tex)
    
    print("Successfully converted to LaTeX.")
