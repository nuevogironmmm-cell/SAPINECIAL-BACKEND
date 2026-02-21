# -*- coding: ascii -*-
"""Second pass: fix remaining ? encoding issues."""

import os
import re

BASE_DIR = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib'

# Unicode accented chars
a_ = '\u00e1'; e_ = '\u00e9'; i_ = '\u00ed'; o_ = '\u00f3'; u_ = '\u00fa'
n_ = '\u00f1'; A_ = '\u00c1'; E_ = '\u00c9'; I_ = '\u00cd'; O_ = '\u00d3'
U_ = '\u00da'; N_ = '\u00d1'; iq = '\u00bf'; ie = '\u00a1'

def build_replacements():
    R = {}
    # ---- Words with n tilde ----
    R["Dise?o"] = "Dise" + n_ + "o"
    R["dise?o"] = "dise" + n_ + "o"
    R["DISE?O"] = "DISE" + N_ + "O"
    R["Dise?ado"] = "Dise" + n_ + "ado"
    R["dise?ado"] = "dise" + n_ + "ado"
    R["Dise?ador"] = "Dise" + n_ + "ador"
    R["rese?a"] = "rese" + n_ + "a"
    R["Ense?a"] = "Ense" + n_ + "a"
    R["ense?a"] = "ense" + n_ + "a"
    R["Cana?n"] = "Cana" + a_ + "n"
    R["CANA?N"] = "CANA" + A_ + "N"
    R["a?ade"] = "a" + n_ + "ade"
    R["A?ade"] = "A" + n_ + "ade"
    R["a?os"] = "a" + n_ + "os"
    R["A?o"] = "A" + n_ + "o"
    R["a?o"] = "a" + n_ + "o"
    R["a?n"] = "a" + u_ + "n"
    R["A?n"] = "A" + u_ + "n"

    # ---- Words with a acute ----
    R["din?mico"] = "din" + a_ + "mico"
    R["din?mica"] = "din" + a_ + "mica"
    R["Mediterr?neo"] = "Mediterr" + a_ + "neo"
    R["MEDITERR?NEO"] = "MEDITERR" + A_ + "NEO"
    R["contempor?neo"] = "contempor" + a_ + "neo"
    R["Contempor?neo"] = "Contempor" + a_ + "neo"
    R["Lev?ntate"] = "Lev" + a_ + "ntate"
    R["lev?ntate"] = "lev" + a_ + "ntate"
    R["levantar?n"] = "levantar" + a_ + "n"
    R["t?ctil"] = "t" + a_ + "ctil"
    R["T?ctil"] = "T" + a_ + "ctil"
    R["seg?n"] = "seg" + u_ + "n"
    R["Seg?n"] = "Seg" + u_ + "n"
    R["SEG?N"] = "SEG" + U_ + "N"
    R["cu?ndo"] = "cu" + a_ + "ndo"
    R["Cu?ndo"] = "Cu" + a_ + "ndo"
    R["CU?NDO"] = "CU" + A_ + "NDO"
    R["cu?ntas"] = "cu" + a_ + "ntas"
    R["Cu?ntas"] = "Cu" + a_ + "ntas"
    R["cu?ntos"] = "cu" + a_ + "ntos"
    R["cu?l"] = "cu" + a_ + "l"
    R["Cu?l"] = "Cu" + a_ + "l"
    R["CU?L"] = "CU" + A_ + "L"
    R["podr?"] = "podr" + a_ 
    R["Podr?"] = "Podr" + a_
    R["podr?s"] = "podr" + a_ + "s"
    R["Podr?s"] = "Podr" + a_ + "s"
    R["podr?n"] = "podr" + a_ + "n"
    R["ser?"] = "ser" + a_
    R["Ser?"] = "Ser" + a_
    R["ser?n"] = "ser" + a_ + "n"
    R["har?"] = "har" + a_
    R["Har?"] = "Har" + a_
    R["har?n"] = "har" + a_ + "n"
    R["estar?"] = "estar" + a_
    R["Estar?"] = "Estar" + a_
    R["tendr?"] = "tendr" + a_
    R["Tendr?"] = "Tendr" + a_
    R["pir?mide"] = "pir" + a_ + "mide"
    R["p?rrafo"] = "p" + a_ + "rrafo"
    R["cer?mica"] = "cer" + a_ + "mica"
    R["AM?N"] = "AM" + O_ + "N"
    R["HIST?RICA"] = "HIST" + O_ + "RICA"
    R["hist?rica"] = "hist" + o_ + "rica"
    R["hist?rico"] = "hist" + o_ + "rico"

    # ---- Words with e acute ----
    R["pedag?gico"] = "pedag" + o_ + "gico"
    R["pedag?gica"] = "pedag" + o_ + "gica"
    R["Ezequ?as"] = "Ezequ" + i_ + "as"
    R["EZEQU?AS"] = "EZEQU" + I_ + "AS"
    R["Nehem?as"] = "Nehem" + i_ + "as"
    R["NEHEM?AS"] = "NEHEM" + I_ + "AS"
    R["?ufrates"] = E_ + "ufrates"
    R["?UFRATES"] = E_ + "UFRATES"

    # ---- Words with i acute ----
    R["l?nea"] = "l" + i_ + "nea"
    R["L?nea"] = "L" + i_ + "nea"
    R["L?NEA"] = "L" + I_ + "NEA"
    R["Cronolog?a"] = "Cronolog" + i_ + "a"
    R["cronolog?a"] = "cronolog" + i_ + "a"
    R["CRONOLOG?A"] = "CRONOLOG" + I_ + "A"
    R["mayor?a"] = "mayor" + i_ + "a"
    R["Mayor?a"] = "Mayor" + i_ + "a"
    R["sabidur?a"] = "sabidur" + i_ + "a"
    R["Sabidur?a"] = "Sabidur" + i_ + "a"
    R["SABIDUR?A"] = "SABIDUR" + I_ + "A"
    R["Teor?a"] = "Teor" + i_ + "a"
    R["teor?a"] = "teor" + i_ + "a"
    R["TEOR?A"] = "TEOR" + I_ + "A"
    R["IMP?O"] = "IMP" + I_ + "O"
    R["imp?o"] = "imp" + i_ + "o"
    R["lev?tico"] = "lev" + i_ + "tico"
    R["Lev?tico"] = "Lev" + i_ + "tico"
    R["LEV?TICO"] = "LEV" + I_ + "TICO"
    R["espec?fica"] = "espec" + i_ + "fica"
    R["espec?fico"] = "espec" + i_ + "fico"
    R["Espec?fica"] = "Espec" + i_ + "fica"
    R["Espec?fico"] = "Espec" + i_ + "fico"
    R["d?a"] = "d" + i_ + "a"
    R["D?a"] = "D" + i_ + "a"
    R["D?A"] = "D" + I_ + "A"
    R["C?rculo"] = "C" + i_ + "rculo"
    R["c?rculo"] = "c" + i_ + "rculo"
    R["C?RCULO"] = "C" + I_ + "RCULO"
    R["biograf?a"] = "biograf" + i_ + "a"
    R["Biograf?a"] = "Biograf" + i_ + "a"
    R["geograf?a"] = "geograf" + i_ + "a"
    R["Geograf?a"] = "Geograf" + i_ + "a"
    R["pedagog?a"] = "pedagog" + i_ + "a"
    R["Pedagog?a"] = "Pedagog" + i_ + "a"
    R["categor?a"] = "categor" + i_ + "a"
    R["Categor?a"] = "Categor" + i_ + "a"
    R["poes?a"] = "poes" + i_ + "a"
    R["Poes?a"] = "Poes" + i_ + "a"
    R["POES?A"] = "POES" + I_ + "A"
    R["filosof?a"] = "filosof" + i_ + "a"
    R["analog?a"] = "analog" + i_ + "a"
    R["metodolog?a"] = "metodolog" + i_ + "a"
    R["tipolog?a"] = "tipolog" + i_ + "a"
    R["tecnolog?a"] = "tecnolog" + i_ + "a"
    R["topograf?a"] = "topograf" + i_ + "a"
    R["Jerusal?n"] = "Jerusal" + e_ + "n"
    R["JERUSAL?N"] = "JERUSAL" + E_ + "N"

    # ---- Words with o acute ----
    R["EXISTI?"] = "EXISTI" + O_
    R["existi?"] = "existi" + o_
    R["revel?"] = "revel" + o_
    R["comenz?"] = "comenz" + o_
    R["Comenz?"] = "Comenz" + o_
    R["C?mo"] = "C" + o_ + "mo"
    R["c?mo"] = "c" + o_ + "mo"
    R["C?MO"] = "C" + O_ + "MO"

    # ---- Words with u acute ----
    R["m?ltiples"] = "m" + u_ + "ltiples"
    R["M?ltiples"] = "M" + u_ + "ltiples"
    R["m?ltiple"] = "m" + u_ + "ltiple"
    R["l?mite"] = "l" + i_ + "mite"
    R["L?mite"] = "L" + i_ + "mite"
    R["L?MITE"] = "L" + I_ + "MITE"

    # ---- Verb forms ----
    R["Env?a"] = "Env" + i_ + "a"
    R["env?a"] = "env" + i_ + "a"
    R["R?pido"] = "R" + a_ + "pido"
    R["R?PIDO"] = "R" + A_ + "PIDO"

    # ---- Inverted punctuation ----
    R["?C?mo"] = iq + "C" + o_ + "mo"
    R["?c?mo"] = iq + "c" + o_ + "mo"
    R["?C?MO"] = iq + "C" + O_ + "MO"
    R["?CU?NDO"] = iq + "CU" + A_ + "NDO"
    R["?Cu?ndo"] = iq + "Cu" + a_ + "ndo"
    R["?cu?ndo"] = iq + "cu" + a_ + "ndo"
    R["?Hasta"] = iq + "Hasta"
    R["?hasta"] = iq + "hasta"
    R["?HASTA"] = iq + "HASTA"
    R["?Reflexi?n"] = iq + "Reflexi" + o_ + "n"

    return R


def fix_suffix_patterns(text):
    """Fix remaining suffix patterns."""
    o = o_; O = O_; i = i_; I = I_; a = a_; A = A_
    
    # General -i?n at word boundary -> -ion with accent (covers reflexion, conexion, region, etc.)
    text = re.sub(r'([a-z\u00e1\u00e9\u00ed\u00f3\u00fa\u00f1])i\?n\b',
                  lambda m: m.group(1) + 'i' + o + 'n', text)
    text = re.sub(r'([A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1])I\?N\b',
                  lambda m: m.group(1) + 'I' + O + 'N', text)
    
    # -?a ending (common for words like sabidur?a, categor?a, etc.) 
    # Only in specific word patterns (to avoid false positives)
    # Already handled by word dict above
    
    return text


def process_file(filepath, replacements):
    fname = os.path.basename(filepath)
    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()
    
    original = text
    
    # Apply suffix patterns
    text = fix_suffix_patterns(text)
    
    # Apply word replacements (sort by length descending to avoid partial matches)
    for wrong in sorted(replacements.keys(), key=len, reverse=True):
        correct = replacements[wrong]
        if wrong in text:
            text = text.replace(wrong, correct)
    
    if text != original:
        with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
            f.write(text)
        changed = sum(1 for a, b in zip(original.split('\n'), text.split('\n')) if a != b)
        print("  Fixed: %-40s (%d lines)" % (fname, changed))
        return changed
    return 0


def main():
    print("=" * 60)
    print("  SECOND PASS - Remaining Encoding Fixes")
    print("=" * 60)
    
    replacements = build_replacements()
    print("Additional patterns: %d" % len(replacements))
    
    dart_files = []
    for root, dirs, files in os.walk(BASE_DIR):
        for f in files:
            if f.endswith('.dart'):
                dart_files.append(os.path.join(root, f))
    
    total = 0
    modified = 0
    for fp in sorted(dart_files):
        n = process_file(fp, replacements)
        if n > 0:
            total += n
            modified += 1
    
    print("\n  Total lines fixed: %d in %d files" % (total, modified))
    
    # Check remaining
    print("\nChecking remaining issues...")
    remaining = 0
    for fp in sorted(dart_files):
        with open(fp, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f, 1):
                if '?' in line and 'http' not in line and '?.' not in line and '??' not in line:
                    if re.search(r'[a-zA-Z]\?[a-zA-Z]', line):
                        print("  %s:%d: %s" % (os.path.basename(fp), i, line.rstrip()[:100]))
                        remaining += 1
    
    if remaining == 0:
        print("  ALL CLEAR - No remaining issues!")
    else:
        print("  %d potential remaining issues" % remaining)


if __name__ == '__main__':
    main()
