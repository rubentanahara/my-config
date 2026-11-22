def fail(errors): (errors | join("\n")) + "\n" | halt_error(1);
def stories: [.epics[] | .sprint as $sprint | .id as $epic | .stories[]
  | . + {epic: $epic, sprint: (if has("sprint") then .sprint else $sprint end)}];
def covers($path): . as $prefix | $prefix == $path or (($prefix | endswith("/")) and ($path | startswith($prefix)));
def overlap($a; $b): [$a[] as $x | $b[] as $y | select(($x | covers($y)) or ($y | covers($x))) | $y];
def claims($shared): [(.owns // [])[] | . as $path | select(any($shared[]; covers($path)) | not)];
