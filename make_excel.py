import zipfile, os, textwrap

# ── data ──────────────────────────────────────────────────────────────────────
rows = [
    ("問題番号", "原文（問題）", "答え", "参照ページ", "判断根拠"),
    ("1",
     "指定通貨建積立利率更改型一時払終身保険（無告知型）（以下「本商品」）には金利変動なリスクがあり、積立利率保証期間中は〈市場価格調整〉が適用される。ただり積立金額が増加している場合でも解約時の市場金利の変動によっては、解約返戻金額が一時払保険料を下まわり損失が生じるおそれがある。",
     "〇", "P.06, P.13-14",
     "P.6に「MVAを行うため金利変動リスクがある」と明記。Q&A(P.13)にも積立金額が増えても元本割れの可能性があると記載。"),
    ("2",
     "契約日・更改時に設定される積立利率は、積立利率保証期間にわたって適用される。積立利率保証期間は契約時・更改時の年齢に応じて10年・20年・30年から選択可能。",
     "〇", "P.05-06",
     "「積立利率は、積立利率保証期間中に変更されることはありません」と記載。保証期間は10・20・30年から選択可能。"),
    ("3",
     "積立利率は毎月1日に設定される新たな数値から当月末日まで同じ値となる。",
     "×", "P.05-06",
     "積立利率は「毎月1日と16日」に設定される。1日だけではなく16日にも設定されるため誤り。"),
    ("4",
     "積立利率の発信は、おおよそ20日頃にソニー生命ホームページに掲示される。",
     "×", "P.05-06",
     "パンフレットには「20日頃」という記載はない。積立利率は毎月1日と16日に設定されるため、20日頃という記述は誤り。"),
    ("5",
     "契約日に設定された積立利率は、積立利率保証期間にわたって保証される。",
     "〇", "P.05-06",
     "「積立利率は、積立利率保証期間中に変更されることはありません」と明記されており正しい。"),
    ("6",
     "契約には申込日の積立利率が適用される。ただり申込日と契約日が異なる場合でも、適用される積立利率は申込日の積立利率となる。",
     "×", "P.05-06",
     "「申込日と契約日が異なる場合、適用される積立利率は、契約日時点の積立利率が適用される」と明記。申込日ではなく契約日の積立利率が適用される。"),
    ("7",
     "前払込外貨換算特約を付加することで、契約者が指定した金額を円で積み込むことができる。ただり端数が生じる。予定日による積込金額が変動することはない。ただしこの特約を付加する場合の基本保険金額は、前払込金額を米ドルに換算した額となる。ただり基本保険金額に端数が生じる場合があることに注意が必要である。",
     "〇", "P.07-08",
     "円払込外貨換算特約により円建で払い込み可能。円払込金額を当社所定の為替レートで換算した額が基本保険金額となり、1セント未満の端数は四捨五入される。"),
    ("8",
     "米ドル建契約の場合に前払込外貨換算死亡保険金最低保証特約を付加することで、年齢に関わらず契約から5年間の死亡保険金は前払込目一時払保険料と同額（前払込の場合は前払込金額）が保証される。",
     "×", "P.07-08",
     "保証期間は年齢によって異なる。5歳〜74歳は「2年または5年」、75歳〜90歳は「2年」であり、「年齢に関わらず5年間」という記述は誤り。"),
    ("9",
     "一時払保険料払込時は、契約者が指定した基本保険金額を毎月払当日のソニー生命指定の発替レートによって換算した金額を払い込んでもらう。誤った金額を積み込まないように注意が必要である。",
     "×", "P.07-08",
     "本商品は一時払（単回払込）であり「毎月払」は存在しない。また、契約者が指定するのは円払込金額であり、それを換算してUSDの基本保険金額が算出される。"),
    ("10",
     "前払込外貨換算死亡保険金最低保証特約について、保証される死亡保険金額は、前払込目一時払保険料の金額（前払込外貨換算特約を付加している場合は前払込金額）の90%となる。",
     "×", "P.07-08",
     "保証額は一時払保険料の円換算額と「同額」（100%）である。90%ではなく全額が最低保証される。"),
    ("11",
     "前払込外貨換算死亡保険金最低保証特約について、前払込目一時払保険料が1,000万円だった場合、特約の保証期間中に発替が高くなり（円安）、死亡保険金額に発替レートを掛けた金額が900万円であっても、支払金額は前払込目一時払保険料の1,000万円となる。発替が安くなり（円高）、死亡保険金額に発替レートを掛けた金額が1,100万円だった場合、同様に、前払込目一時払保険料の1,000万円が支払われる。",
     "×", "P.07-08",
     "円安ケース（900万＜1,000万）→1,000万円支払いは正しい。しかし円高ケース（1,100万＞1,000万）は①と②のいずれか大きい金額が支払われるため、1,100万円が支払われる。「同様に1,000万円」という記述が誤り。"),
    ("12",
     "前払込外貨換算死亡保険金最低保証特約の費用は、積立利率から最低保証期間に応じて差し引かれる仕組みとなっている。前払込目死亡保険金最低保証期間中は、特約を付加していない契約から適用される積立利率が低くなる。なお、差引率は被保険者年齢・最低保証期間によって異なる。",
     "〇", "P.11-12",
     "「円換算した一時払保険料と同額を最低保証するための率を主契約の積立利率から差し引く」「特約を付加しない場合に比べ主契約に適用される利率が低くなる」「被保険者の年齢および円換算死亡保険金最低保証期間に応じて異なる」と全て一致。"),
    ("13",
     "死亡保険金額は、支払事由発生時点の積立金額または解約返戻金額のいずれか小さい金額となる。",
     "×", "P.03-04, P.05-06",
     "死亡保険金は「積立金額または解約返戻金額のいずれか大きい金額」が支払われる。「小さい」という記述が誤り。"),
    ("14",
     "災害死亡保険金額は、死亡保険金額に積立金額の10%を加えた金額であるが、死亡保険金額より大きくなる。",
     "〇", "P.03-04, P.05-06",
     "「死亡保険金額と同額に積立金額の10％を加えた額を災害死亡保険金としてお支払い」と明記。積立金額10%が加算される分、常に死亡保険金より大きくなる。"),
    ("15",
     "本商品の最高基本保険金額は、（契約あたり）米ドルの場合はドルで、円の場合で7億円である。（※米ドル建の場合は、換算の基本保険金額になる。）",
     "〇", "P.09",
     "取扱保険金額：米ドル建は1万〜1,000万米ドル未満かつ円換算7億円、円建は100万円〜7億円と記載。最高額は7億円（またはドル換算相当）で正しい。"),
    ("16",
     "本商品では、契約者貸付の取り扱いを行う。",
     "×", "P.09",
     "「契約者貸付のお取り扱いはありません。」と明記されており、誤り。"),
    ("17",
     "市場金利の変動に応じて、運用資産（債券等）の価格変動が死亡保険金に反映される仕組みを市場価格調整という。",
     "×", "P.09-10",
     "市場価格調整（MVA）は「解約返戻金額に反映させる」仕組みであり、死亡保険金には反映されない。"),
    ("18",
     "一般的に、市場金利が低下すると債券価格は上昇し、市場金利が上昇すると債券価格は下落する。",
     "〇", "P.09-10",
     "パンフレットの図解に「市場金利が1%に下がったとき→保有している債券の価格が上昇」「市場金利が5%に上がったとき→保有している債券の価格が下落」と明示。"),
    ("19",
     "市場価格調整による解約時の金利変動リスクは保険会社が負担する。",
     "×", "P.05-06",
     "「以下のリスクは保険契約者または受取人に帰属します」と明記。金利変動リスクは保険会社ではなく契約者・受取人が負担する。"),
    ("20",
     "指定通貨建積立利率更改型一時払終身保険（無告知型）の積立利率保証期間中の解約・減額においては、契約時の市場金利に比べ解約時の市場金利が高い場合、解約返戻金額は積立金額を上回る一方、契約時の市場金利に比べ解約時の市場金利が低い場合、解約返戻金額は積立金額を上回る（米ドル建の場合、発替の変動は考慮しない前提）",
     "×", "P.05-06, P.09-10",
     "解約時市場金利が高い場合→解約返戻金額は積立金額を下まわる（上回るは誤り）。解約時市場金利が低い場合→上まわるは正しい。前半が逆になっているため×。"),
    ("21",
     "本商品では、市場価格調整によって解約返戻金額が変動する仕組みになっているが、積立利率保証期間更改日には市場価格調整が適用されない。",
     "〇", "P.09-10",
     "「積立利率保証期間更改日に解約等をされる場合、市場価格調整（MVA）は行いません」と明記。"),
    ("22",
     "契約日または積立利率保証期間更改日から解約・減額日までの経過期間が長いほど、解約返戻金に対する市場価格調整の影響が大きくなる。",
     "×", "P.05-06",
     "「経過期間が短いほど、解約返戻金額に対する市場価格調整（MVA）の影響は大きくなり金利変動リスクは大きくなります」と明記。長いほどではなく短いほど影響が大きい。"),
    ("23",
     "本商品について、積立利率保証期間更改日以外に解約した場合、換算した解約返戻金額が、契約者の想定した大きく増減することがある（発替の影響は考慮しない）",
     "〇", "P.09-10, P.13-14",
     "更改日以外の解約にはMVAが適用され、基準金利の変動幅によって解約返戻金額が大きく増減する可能性がある。Q&Aにも具体例で説明されている。"),
    ("24",
     "積立利率保証期間を更改した場合、新しい積立利率保証期間では、解約控除と同様に市場価格調整の適用はない。",
     "×", "P.09-10",
     "新しい積立利率保証期間中でも、更改日以外の日に解約・減額する場合はMVAが適用される。更改日のみMVAが適用されない。"),
    ("25",
     "各リスクの説明は、お客様の契約締結結果に応じ実施されることで、中途解約時・保険料支払い時の説明を省略することが可能。",
     "〇", "P.01（ご確認事項）",
     "本商品は一時払のため保険料支払いは契約時の1回のみ。契約時に各リスク（MVA・解約控除・為替等）を網羅的に説明することで、その後の個別場面での重複説明を省略できる。"),
]

# ── XML helpers ───────────────────────────────────────────────────────────────
def esc(s):
    return (s.replace("&","&amp;").replace("<","&lt;")
             .replace(">","&gt;").replace('"',"&quot;").replace("'","&apos;"))

def col_letter(n):          # 1-based column index → letter(s)
    s = ""
    while n:
        n, r = divmod(n-1, 26)
        s = chr(65+r) + s
    return s

def cell_ref(r, c):         # 1-based row, col
    return f"{col_letter(c)}{r}"

# ── build worksheet XML ───────────────────────────────────────────────────────
COL_WIDTHS = [8, 60, 6, 14, 80]   # characters
HDR_FILL   = "1F497D"              # dark blue
HDR_FONT   = "FFFFFF"              # white
ALT_FILL   = "DCE6F1"              # light blue for even rows

# shared strings
strings = []
str_index = {}

def si(text):
    if text not in str_index:
        str_index[text] = len(strings)
        strings.append(text)
    return str_index[text]

# collect all strings
for row in rows:
    for cell in row:
        si(cell)

# shared strings XML
def shared_strings_xml():
    parts = [f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
             f'<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"'
             f' count="{len(strings)}" uniqueCount="{len(strings)}">']
    for s in strings:
        parts.append(f"<si><t xml:space=\"preserve\">{esc(s)}</t></si>")
    parts.append("</sst>")
    return "".join(parts)

# styles XML  (4 cell formats: header, 〇-row, ×-row, alt-even)
def styles_xml():
    return textwrap.dedent("""\
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
      <fonts count="3">
        <font><sz val="11"/><name val="Calibri"/></font>
        <font><sz val="11"/><b/><color rgb="FF{hf}"/><name val="Calibri"/></font>
        <font><sz val="11"/><b/><name val="Calibri"/></font>
      </fonts>
      <fills count="5">
        <fill><patternFill patternType="none"/></fill>
        <fill><patternFill patternType="gray125"/></fill>
        <fill><patternFill patternType="solid"><fgColor rgb="FF{hb}"/></patternFill></fill>
        <fill><patternFill patternType="solid"><fgColor rgb="FF{ab}"/></patternFill></fill>
        <fill><patternFill patternType="solid"><fgColor rgb="FFE2EFDA"/></patternFill></fill>
      </fills>
      <borders count="2">
        <border><left/><right/><top/><bottom/><diagonal/></border>
        <border>
          <left style="thin"><color rgb="FF000000"/></left>
          <right style="thin"><color rgb="FF000000"/></right>
          <top style="thin"><color rgb="FF000000"/></top>
          <bottom style="thin"><color rgb="FF000000"/></bottom>
        </border>
      </borders>
      <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
      <cellXfs count="6">
        <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
        <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1">
          <alignment wrapText="1" vertical="center" horizontal="center"/>
        </xf>
        <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1">
          <alignment wrapText="1" vertical="top"/>
        </xf>
        <xf numFmtId="0" fontId="2" fillId="0" borderId="1" xfId="0" applyFont="1" applyBorder="1" applyAlignment="1">
          <alignment wrapText="1" vertical="center" horizontal="center"/>
        </xf>
        <xf numFmtId="0" fontId="0" fillId="3" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1">
          <alignment wrapText="1" vertical="top"/>
        </xf>
        <xf numFmtId="0" fontId="0" fillId="4" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1">
          <alignment wrapText="1" vertical="top"/>
        </xf>
      </cellXfs>
    </styleSheet>
    """).format(hf=HDR_FONT, hb=HDR_FILL, ab=ALT_FILL)

def worksheet_xml():
    cols = "".join(
        f'<col min="{i+1}" max="{i+1}" width="{w}" bestFit="1" customWidth="1"/>'
        for i, w in enumerate(COL_WIDTHS)
    )
    cell_rows = []
    for ri, row in enumerate(rows, 1):
        cells = []
        for ci, val in enumerate(row, 1):
            ref = cell_ref(ri, ci)
            if ri == 1:                 # header
                s = 1
            elif ci == 3:               # answer column bold centred
                s = 3
            elif ri % 2 == 0:           # alt fill
                s = 4
            else:
                s = 2
            idx = si(val)
            cells.append(f'<c r="{ref}" t="s" s="{s}"><v>{idx}</v></c>')
        ht = 45 if ri == 1 else 80
        cell_rows.append(
            f'<row r="{ri}" ht="{ht}" customHeight="1">{"".join(cells)}</row>'
        )
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        f'<cols>{cols}</cols>'
        '<sheetData>'
        + "".join(cell_rows)
        + '</sheetData>'
        '<sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>'
        '</worksheet>'
    )

# ── assemble xlsx (zip) ───────────────────────────────────────────────────────
OUT = "/home/shuic/projects/OsanpoRecord_2025/OA116_exam_answers.xlsx"

CONTENT_TYPES = """\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml"  ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/sharedStrings.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
  <Override PartName="/xl/styles.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>"""

RELS = """\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
    Target="xl/workbook.xml"/>
</Relationships>"""

WORKBOOK = """\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="試験解答" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>"""

WB_RELS = """\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
    Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings"
    Target="sharedStrings.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
    Target="styles.xml"/>
</Relationships>"""

with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", CONTENT_TYPES)
    z.writestr("_rels/.rels",         RELS)
    z.writestr("xl/workbook.xml",     WORKBOOK)
    z.writestr("xl/_rels/workbook.xml.rels", WB_RELS)
    z.writestr("xl/worksheets/sheet1.xml",   worksheet_xml())
    z.writestr("xl/sharedStrings.xml",        shared_strings_xml())
    z.writestr("xl/styles.xml",               styles_xml())

print(f"Created: {OUT}  ({os.path.getsize(OUT):,} bytes)")
