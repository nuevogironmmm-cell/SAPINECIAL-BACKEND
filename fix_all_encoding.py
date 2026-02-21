# -*- coding: ascii -*-
"""Fix all encoding issues in Flutter Dart files."""

import os
import re
import shutil
from datetime import datetime

BASE_DIR = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib'
BACKUP_DIR = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\_backup_encoding'

# Unicode chars
a_ac = '\u00e1'  # a acute
e_ac = '\u00e9'  # e acute
i_ac = '\u00ed'  # i acute
o_ac = '\u00f3'  # o acute
u_ac = '\u00fa'  # u acute
n_ti = '\u00f1'  # n tilde
A_ac = '\u00c1'  # A acute
E_ac = '\u00c9'  # E acute
I_ac = '\u00cd'  # I acute
O_ac = '\u00d3'  # O acute
U_ac = '\u00da'  # U acute
N_ti = '\u00d1'  # N tilde
u_di = '\u00fc'  # u dieresis
inv_q = '\u00bf' # inverted question mark
inv_e = '\u00a1' # inverted exclamation mark


def smart_decode(data):
    """Decode mixed UTF-8/CP1252 bytes."""
    result = []
    i = 0
    n = len(data)
    while i < n:
        b = data[i]
        if b < 0x80:
            result.append(chr(b))
            i += 1
            continue
        # Try 4-byte UTF-8
        if 0xF0 <= b <= 0xF7 and i + 3 < n:
            b1, b2, b3 = data[i+1], data[i+2], data[i+3]
            if 0x80 <= b1 <= 0xBF and 0x80 <= b2 <= 0xBF and 0x80 <= b3 <= 0xBF:
                try:
                    ch = data[i:i+4].decode('utf-8')
                    result.append(ch)
                    i += 4
                    continue
                except:
                    pass
        # Try 3-byte UTF-8
        if 0xE0 <= b <= 0xEF and i + 2 < n:
            b1, b2 = data[i+1], data[i+2]
            if 0x80 <= b1 <= 0xBF and 0x80 <= b2 <= 0xBF:
                try:
                    ch = data[i:i+3].decode('utf-8')
                    result.append(ch)
                    i += 3
                    continue
                except:
                    pass
        # Try 2-byte UTF-8
        if 0xC0 <= b <= 0xDF and i + 1 < n:
            b1 = data[i+1]
            if 0x80 <= b1 <= 0xBF:
                try:
                    ch = data[i:i+2].decode('utf-8')
                    result.append(ch)
                    i += 2
                    continue
                except:
                    pass
        # Fallback: CP1252
        try:
            result.append(data[i:i+1].decode('cp1252'))
        except:
            result.append('?')
        i += 1
    return ''.join(result)


def build_replacements():
    """Build replacement dictionary for corrupted ? chars."""
    R = {}

    # -- Names --
    R["Garc?a"] = "Garc" + i_ac + "a"
    R["Mart?nez"] = "Mart" + i_ac + "nez"
    R["Mar?a"] = "Mar" + i_ac + "a"
    R["MAR?A"] = "MAR" + I_ac + "A"
    R["L?pez"] = "L" + o_ac + "pez"
    R["L?PEZ"] = "L" + O_ac + "PEZ"
    R["Rodr?guez"] = "Rodr" + i_ac + "guez"
    R["Mois?s"] = "Mois" + e_ac + "s"
    R["MOIS?S"] = "MOIS" + E_ac + "S"
    R["Salom?n"] = "Salom" + o_ac + "n"
    R["SALOM?N"] = "SALOM" + O_ac + "N"
    R["Jehov?"] = "Jehov" + a_ac
    R["JEHOV?"] = "JEHOV" + A_ac
    R["Esp?ritu"] = "Esp" + i_ac + "ritu"
    R["P?rez"] = "P" + e_ac + "rez"

    # -- Words with n tilde --
    R["espa?ol"] = "espa" + n_ti + "ol"
    R["Espa?ol"] = "Espa" + n_ti + "ol"
    R["ESPA?OL"] = "ESPA" + N_ti + "OL"
    R["contrase?a"] = "contrase" + n_ti + "a"
    R["Contrase?a"] = "Contrase" + n_ti + "a"
    R["CONTRASE?A"] = "CONTRASE" + N_ti + "A"
    R["ense?anza"] = "ense" + n_ti + "anza"
    R["Ense?anza"] = "Ense" + n_ti + "anza"
    R["ENSE?ANZA"] = "ENSE" + N_ti + "ANZA"
    R["DESEMPE?O"] = "DESEMPE" + N_ti + "O"
    R["desempe?o"] = "desempe" + n_ti + "o"
    R["peque?a"] = "peque" + n_ti + "a"
    R["peque?o"] = "peque" + n_ti + "o"
    R["Peque?o"] = "Peque" + n_ti + "o"
    R["a?o"] = "a" + n_ti + "o"
    R["A?O"] = "A" + N_ti + "O"
    R["a?os"] = "a" + n_ti + "os"
    R["compa?ero"] = "compa" + n_ti + "ero"
    R["compa?era"] = "compa" + n_ti + "era"
    R["enga?o"] = "enga" + n_ti + "o"
    R["se?or"] = "se" + n_ti + "or"
    R["Se?or"] = "Se" + n_ti + "or"
    R["SE?OR"] = "SE" + N_ti + "OR"
    R["ni?o"] = "ni" + n_ti + "o"
    R["ni?os"] = "ni" + n_ti + "os"
    R["sue?o"] = "sue" + n_ti + "o"
    R["due?o"] = "due" + n_ti + "o"
    R["monta?a"] = "monta" + n_ti + "a"
    R["extra?o"] = "extra" + n_ti + "o"
    R["da?o"] = "da" + n_ti + "o"
    R["campa?a"] = "campa" + n_ti + "a"
    R["tama?o"] = "tama" + n_ti + "o"
    R["Tama?o"] = "Tama" + n_ti + "o"
    R["rese?a"] = "rese" + n_ti + "a"
    R["oto?o"] = "oto" + n_ti + "o"
    R["Ense?a"] = "Ense" + n_ti + "a"
    R["ense?a"] = "ense" + n_ti + "a"

    # -- Words with a acute --
    R["m?s"] = "m" + a_ac + "s"
    R["M?S"] = "M" + A_ac + "S"
    R["est?"] = "est" + a_ac
    R["Est?"] = "Est" + a_ac
    R["EST?"] = "EST" + A_ac
    R["est?n"] = "est" + a_ac + "n"
    R["Est?n"] = "Est" + a_ac + "n"
    R["est?s"] = "est" + a_ac + "s"
    R["Est?s"] = "Est" + a_ac + "s"
    R["r?pido"] = "r" + a_ac + "pido"
    R["R?PIDO"] = "R" + A_ac + "PIDO"
    R["r?pida"] = "r" + a_ac + "pida"
    R["r?pidamente"] = "r" + a_ac + "pidamente"
    R["m?vil"] = "m" + o_ac + "vil"
    R["m?ximo"] = "m" + a_ac + "ximo"
    R["M?ximo"] = "M" + a_ac + "ximo"
    R["M?XIMO"] = "M" + A_ac + "XIMO"
    R["m?nimo"] = "m" + i_ac + "nimo"
    R["M?nimo"] = "M" + i_ac + "nimo"
    R["M?NIMO"] = "M" + I_ac + "NIMO"
    R["p?gina"] = "p" + a_ac + "gina"
    R["P?gina"] = "P" + a_ac + "gina"
    R["pr?ctica"] = "pr" + a_ac + "ctica"
    R["Pr?ctica"] = "Pr" + a_ac + "ctica"
    R["pr?cticas"] = "pr" + a_ac + "cticas"
    R["autom?ticamente"] = "autom" + a_ac + "ticamente"
    R["autom?tica"] = "autom" + a_ac + "tica"
    R["gr?fico"] = "gr" + a_ac + "fico"
    R["gr?ficos"] = "gr" + a_ac + "ficos"
    R["Gr?ficos"] = "gr" + a_ac + "ficos"
    R["di?logo"] = "di" + a_ac + "logo"
    R["Di?logo"] = "Di" + a_ac + "logo"
    R["DI?LOGO"] = "DI" + A_ac + "LOGO"
    R["b?sico"] = "b" + a_ac + "sico"
    R["b?sica"] = "b" + a_ac + "sica"
    R["b?sicas"] = "b" + a_ac + "sicas"
    R["b?sicos"] = "b" + a_ac + "sicos"
    R["cl?sico"] = "cl" + a_ac + "sico"
    R["cl?sica"] = "cl" + a_ac + "sica"
    R["cl?sicas"] = "cl" + a_ac + "sicas"
    R["im?genes"] = "im" + a_ac + "genes"
    R["an?lisis"] = "an" + a_ac + "lisis"
    R["An?lisis"] = "An" + a_ac + "lisis"
    R["AN?LISIS"] = "AN" + A_ac + "LISIS"
    R["c?lculo"] = "c" + a_ac + "lculo"
    R["s?bado"] = "s" + a_ac + "bado"
    R["?rbitro"] = a_ac + "rbitro"
    R["?rea"] = a_ac + "rea"
    R["?reas"] = a_ac + "reas"
    R["c?mara"] = "c" + a_ac + "mara"
    R["par?metro"] = "par" + a_ac + "metro"
    R["car?cter"] = "car" + a_ac + "cter"
    R["caracteristica"] = "caracter" + i_ac + "stica"
    R["Caracter?sticas"] = "Caracter" + i_ac + "sticas"
    R["caracter?stica"] = "caracter" + i_ac + "stica"

    # -- Words with e acute --
    R["estad?stico"] = "estad" + i_ac + "stico"
    R["Estad?stico"] = "Estad" + i_ac + "stico"
    R["ESTAD?STICO"] = "ESTAD" + I_ac + "STICO"
    R["estad?stica"] = "estad" + i_ac + "stica"
    R["Estad?stica"] = "Estad" + i_ac + "stica"
    R["ESTAD?STICA"] = "ESTAD" + I_ac + "STICA"
    R["estad?sticas"] = "estad" + i_ac + "sticas"
    R["Estad?sticas"] = "Estad" + i_ac + "sticas"
    R["ESTAD?STICAS"] = "ESTAD" + I_ac + "STICAS"
    R["est?ndar"] = "est" + a_ac + "ndar"
    R["Est?ndar"] = "Est" + a_ac + "ndar"
    R["EST?NDAR"] = "EST" + A_ac + "NDAR"
    R["M?TRICAS"] = "M" + E_ac + "TRICAS"
    R["m?tricas"] = "m" + e_ac + "tricas"
    R["M?tricas"] = "M" + e_ac + "tricas"
    R["R?CORD"] = "R" + E_ac + "CORD"
    R["r?cord"] = "r" + e_ac + "cord"
    R["?xito"] = e_ac + "xito"
    R["?XITO"] = E_ac + "XITO"
    R["tambi?n"] = "tambi" + e_ac + "n"
    R["Tambi?n"] = "Tambi" + e_ac + "n"
    R["despu?s"] = "despu" + e_ac + "s"
    R["Despu?s"] = "Despu" + e_ac + "s"
    R["tel?fono"] = "tel" + e_ac + "fono"
    R["Tel?fono"] = "Tel" + e_ac + "fono"

    # -- Words with i acute --
    R["?cono"] = i_ac + "cono"
    R["?CONO"] = I_ac + "CONO"
    R["ra?z"] = "ra" + i_ac + "z"
    R["Ra?z"] = "Ra" + i_ac + "z"
    R["cl?max"] = "cl" + i_ac + "max"
    R["t?tulo"] = "t" + i_ac + "tulo"
    R["T?tulo"] = "T" + i_ac + "tulo"
    R["T?TULO"] = "T" + I_ac + "TULO"
    R["?ndice"] = i_ac + "ndice"
    R["?NDICE"] = I_ac + "NDICE"
    R["b?blico"] = "b" + i_ac + "blico"
    R["B?blico"] = "B" + i_ac + "blico"
    R["b?blica"] = "b" + i_ac + "blica"
    R["B?blica"] = "B" + i_ac + "blica"
    R["po?tico"] = "po" + e_ac + "tico"
    R["po?tica"] = "po" + e_ac + "tica"

    # -- Words with u acute --
    R["may?sculas"] = "may" + u_ac + "sculas"
    R["may?scula"] = "may" + u_ac + "scula"
    R["MAY?SCULAS"] = "MAY" + U_ac + "SCULAS"
    R["min?sculas"] = "min" + u_ac + "sculas"
    R["m?sica"] = "m" + u_ac + "sica"
    R["M?sica"] = "M" + u_ac + "sica"
    R["?ltimo"] = u_ac + "ltimo"
    R["?ltima"] = u_ac + "ltima"
    R["?nico"] = u_ac + "nico"
    R["?nica"] = u_ac + "nica"
    R["p?blico"] = "p" + u_ac + "blico"
    R["P?blico"] = "P" + u_ac + "blico"
    R["?til"] = u_ac + "til"

    # -- Words with o acute (not in -cion suffix) --
    R["Bot?n"] = "Bot" + o_ac + "n"
    R["bot?n"] = "bot" + o_ac + "n"
    R["BOT?N"] = "BOT" + O_ac + "N"
    R["L?GICA"] = "L" + O_ac + "GICA"
    R["l?gica"] = "l" + o_ac + "gica"
    R["c?digo"] = "c" + o_ac + "digo"
    R["C?digo"] = "C" + o_ac + "digo"
    R["C?DIGO"] = "C" + O_ac + "DIGO"
    R["m?dulo"] = "m" + o_ac + "dulo"
    R["M?dulo"] = "M" + o_ac + "dulo"
    R["m?todo"] = "m" + e_ac + "todo"
    R["M?todo"] = "M" + e_ac + "todo"
    R["per?odo"] = "per" + i_ac + "odo"
    R["Per?odo"] = "Per" + i_ac + "odo"
    R["pr?ximo"] = "pr" + o_ac + "ximo"
    R["Pr?ximo"] = "Pr" + o_ac + "ximo"
    R["pr?xima"] = "pr" + o_ac + "xima"
    R["prop?sito"] = "prop" + o_ac + "sito"
    R["?ptico"] = o_ac + "ptico"

    # -- Verb forms --
    R["respondi?"] = "respondi" + o_ac
    R["uni?"] = "uni" + o_ac
    R["desconect?"] = "desconect" + o_ac
    R["envi?"] = "envi" + o_ac
    R["devolvi?"] = "devolvi" + o_ac
    R["fall?"] = "fall" + o_ac
    R["termin?"] = "termin" + o_ac
    R["inici?"] = "inici" + o_ac
    R["sugiri?"] = "sugiri" + o_ac
    R["Ocurri?"] = "Ocurri" + o_ac

    # Future tense verbs
    R["mostrar?"] = "mostrar" + a_ac
    R["detectar?"] = "detectar" + a_ac
    R["navegar?"] = "navegar" + a_ac
    R["cerrar?"] = "cerrar" + a_ac
    R["cargar?"] = "cargara" + a_ac
    R["seleccionar?"] = "seleccionar" + a_ac
    R["iniciar?"] = "iniciar" + a_ac
    R["generar?"] = "generar" + a_ac
    R["restaurar?"] = "restaurar" + a_ac
    R["verificar?"] = "verificar" + a_ac
    R["eliminar?"] = "eliminar" + a_ac
    R["funcionar?"] = "funcionar" + a_ac
    R["desconectar?"] = "desconectar" + a_ac
    R["conectar?"] = "conectar" + a_ac

    # -- Inverted punctuation --
    R["?Seguro"] = inv_q + "Seguro"
    R["?seguro"] = inv_q + "seguro"
    R["?Desea"] = inv_q + "Desea"
    R["?desea"] = inv_q + "desea"
    R["?Est?s"] = inv_q + "Est" + a_ac + "s"

    return R


def fix_suffix_patterns(text):
    """Fix common suffix patterns using regex."""
    o = o_ac
    O = O_ac

    # -ci?n -> -cion (with accent)
    text = re.sub(r'([a-z\u00e1\u00e9\u00ed\u00f3\u00fa\u00f1])ci\?n\b',
                  lambda m: m.group(1) + 'ci' + o + 'n', text)
    text = re.sub(r'([A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1])CI\?N\b',
                  lambda m: m.group(1) + 'CI' + O + 'N', text)

    # -si?n -> -sion (with accent)
    text = re.sub(r'([a-z\u00e1\u00e9\u00ed\u00f3\u00fa\u00f1])si\?n\b',
                  lambda m: m.group(1) + 'si' + o + 'n', text)
    text = re.sub(r'([A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1])SI\?N\b',
                  lambda m: m.group(1) + 'SI' + O + 'N', text)

    return text


def fix_file(filepath, replacements):
    """Fix encoding in a single file."""
    with open(filepath, 'rb') as f:
        raw = f.read()

    fname = os.path.basename(filepath)
    info = {'file': fname, 'enc_fixed': False, 'lines_fixed': 0, 'details': []}

    # Decode
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        text = smart_decode(raw)
        info['enc_fixed'] = True
        info['details'].append("Fixed mixed UTF-8/CP1252 encoding")

    original = text

    # Apply suffix patterns first
    text = fix_suffix_patterns(text)

    # Apply word replacements
    for wrong, correct in replacements.items():
        if wrong in text:
            text = text.replace(wrong, correct)

    # Count changed lines
    if text != original:
        orig_lines = original.split('\n')
        new_lines = text.split('\n')
        changed = sum(1 for a, b in zip(orig_lines, new_lines) if a != b)
        info['lines_fixed'] = changed
        info['details'].append("Fixed ? chars in %d lines" % changed)

    # Write if changed
    if text != original or info['enc_fixed']:
        with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
            f.write(text)
        return info

    return None


def main():
    print("=" * 65)
    print("   ENCODING FIXER - Literatura Sapiencial App")
    print("   Date: %s" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    print("=" * 65)

    # Collect dart files
    dart_files = []
    for root, dirs, files in os.walk(BASE_DIR):
        for f in files:
            if f.endswith('.dart'):
                dart_files.append(os.path.join(root, f))

    print("\nDart files found: %d" % len(dart_files))

    # Backup
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)
    for fp in dart_files:
        rel = os.path.relpath(fp, BASE_DIR)
        bp = os.path.join(BACKUP_DIR, rel)
        os.makedirs(os.path.dirname(bp), exist_ok=True)
        shutil.copy2(fp, bp)
    print("Backup created: %s" % BACKUP_DIR)

    # Build replacements
    replacements = build_replacements()
    print("Replacement patterns: %d" % len(replacements))

    # Process
    results = []
    for fp in sorted(dart_files):
        r = fix_file(fp, replacements)
        if r:
            results.append(r)

    # Report
    print("\n" + "=" * 65)
    print("   RESULTS")
    print("=" * 65)

    if not results:
        print("\nNo issues found.")
        return

    total_enc = 0
    total_lines = 0
    for r in results:
        flags = []
        if r['enc_fixed']:
            flags.append("ENC")
            total_enc += 1
        if r['lines_fixed'] > 0:
            flags.append("%d lines" % r['lines_fixed'])
            total_lines += r['lines_fixed']
        print("  %-40s %s" % (r['file'], " | ".join(flags)))
        for d in r['details']:
            print("    > %s" % d)

    print("\n" + "-" * 65)
    print("  Files with encoding fixed:  %d" % total_enc)
    print("  Total lines corrected:      %d" % total_lines)
    print("  Total files modified:       %d" % len(results))
    print("=" * 65)

    # Verify
    print("\nVerifying all files are valid UTF-8...")
    ok = True
    for fp in dart_files:
        try:
            with open(fp, 'r', encoding='utf-8') as f:
                f.read()
        except UnicodeDecodeError as e:
            print("  FAIL: %s - %s" % (os.path.basename(fp), e))
            ok = False
    if ok:
        print("  ALL FILES OK - Valid UTF-8")

    # Check remaining ? in non-URL contexts
    print("\nChecking for remaining '?' issues...")
    remaining = 0
    for fp in dart_files:
        with open(fp, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f, 1):
                # Skip URLs and null-aware operators
                if '?' in line and 'http' not in line and '?.' not in line and '??' not in line and '?.toString' not in line:
                    # Check for letter?letter pattern (likely corrupted accent)
                    if re.search(r'[a-zA-Z]\?[a-zA-Z]', line):
                        print("  REMAINING: %s:%d: %s" % (os.path.basename(fp), i, line.rstrip()[:100]))
                        remaining += 1
    if remaining == 0:
        print("  No remaining issues found")
    else:
        print("  %d potential remaining issues" % remaining)


if __name__ == '__main__':
    main()
