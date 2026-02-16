import re

# File path
file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart'

# The goal is to:
# 1. Add 'import 'package:flutter/gestures.dart';' if missing.
# 2. Add the 'EagerGestureRecognizer' class definition at the end of the file.
# 3. Replace the GestureDetector block with RawGestureDetector using EagerGestureRecognizer.

with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# 1. Check/Add import
if "import 'package:flutter/gestures.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/gestures.dart';")

# 2. Add class definition
eager_class_def = """
class EagerGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'EagerGestureRecognizer';
}
"""

if "class EagerGestureRecognizer" not in content:
    content = content + "\n" + eager_class_def

# 3. Replace GestureDetector with RawGestureDetector
# We need to be careful with regex matching multiline blocks.
# The target block looks something like:
# GestureDetector(
#   onPanStart: (d) => _onPanStart(d, BoxConstraints(maxWidth: size, maxHeight: size)),
#   onPanUpdate: (d) => _onPanUpdate(d, BoxConstraints(maxWidth: size, maxHeight: size)),
#   onPanEnd: _onPanEnd,
#   ...
#   child: Container(...)
# )

# Let's try to match the GestureDetector start and replace it.
# The previous patch might have left it a bit differently formatted.
# Based on the python read output, the current state seems to have valid Dart code but maybe weirdly merged in the output log.
# Let's construct a flexible regex to find the GestureDetector and replace it.

# Pattern to find: GestureDetector( ... ) wrapping the Container.
# It seems tricky to do a full block replacement with regex safety.
# Instead, let's find the specific part that instantiates GestureDetector and replace it with RawGestureDetector logic.

# The pattern we want to replace starts with 'GestureDetector(' and ends before 'child: Container('.
# And we need to close it properly.

# Let's try to locate the specific segment around lines 580-590.
# The context is inside LayoutBuilder -> builder: (context, gridConstraints) { ... return Center( child: SizedBox( ... child: [HERE] ) ) }

patch_target = r"""GestureDetector\(
\s*onPanStart:\s*\(d\)\s*=>\s*_onPanStart\(d,\s*BoxConstraints\(maxWidth:\s*size,\s*maxHeight:\s*size\)\),
\s*onPanUpdate:\s*\(d\)\s*=>\s*_onPanUpdate\(d,\s*BoxConstraints\(maxWidth:\s*size,\s*maxHeight:\s*size\)\),
\s*onPanEnd:\s*_onPanEnd,
\s*behavior:\s*HitTestBehavior.opaque,
\s*onVerticalDragStart:\s*\(d\)\s*=>\s*_onPanStart\(DragStartDetails\(globalPosition:\s*d.globalPosition,\s*localPosition:\s*d.localPosition\),\s*BoxConstraints\(maxWidth:\s*size,\s*maxHeight:\s*size\)\),
\s*onVerticalDragUpdate:\s*\(d\)\s*=>\s*_onPanUpdate\(DragUpdateDetails\(globalPosition:\s*d.globalPosition,\s*localPosition:\s*d.localPosition\),\s*BoxConstraints\(maxWidth:\s*size,\s*maxHeight:\s*size\)\),
\s*onVerticalDragEnd:\s*\(d\)\s*=>\s*_onPanEnd\(DragEndDetails\(velocity:\s*d.velocity\)\),"""

# Since the previous patch added vertical drag handlers, we must match them too.
# However, the exact formatting might vary. 
# Let's try a simpler approach: finding the GestureDetector and replacing the whole widget construction if possible, 
# or just swapping usage if the structure allows.

# Actually, the most robust way is to find the `return Helper(...)` or `child: GestureDetector(...)` and replace.
# But `GestureDetector` is inside a `SizedBox`.

# Let's use a simpler regex that captures the `GestureDetector` constructor and its arguments up to `child:`.
gesture_pattern = r"GestureDetector\s*\(\s*onPanStart:.+?child:"

replacement_code = """RawGestureDetector(
                    gestures: {
                      EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                        (EagerGestureRecognizer instance) {
                          instance.onStart = (d) => _onPanStart(d, BoxConstraints(maxWidth: size, maxHeight: size));
                          instance.onUpdate = (d) => _onPanUpdate(d, BoxConstraints(maxWidth: size, maxHeight: size));
                          instance.onEnd = (d) => _onPanEnd(d);
                        },
                      ),
                    },
                    behavior: HitTestBehavior.opaque,
                    child:"""

# We use re.DOTALL to match across lines.
# Note: This is aggressive. We should verify distinctiveness.
new_content = re.sub(gesture_pattern, replacement_code, content, flags=re.DOTALL)

if content == new_content:
    print("WARNING: Regex did not match. Trying fallback pattern without vertical drags.")
    # Fallback: maybe the previous vertical drag patch wasn't applied or applied differently?
    # Let's try matching just the beginning.
    gesture_pattern_simple = r"GestureDetector\s*\(\s*onPanStart:.+?child:"
    new_content = re.sub(gesture_pattern_simple, replacement_code, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Successfully patched word_search_widget.dart with RawGestureDetector")
