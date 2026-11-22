def text: type == "string" and length > 0;
def normalize: {id, name, title, area: (.area // ""), priority: (.priority // "P1"), estimate: (.estimate // ""),
  acceptance_criteria, depends_on: (.depends_on // []), tasks: (.tasks // []), owns: (.owns // []), prd: (.prd // ""), test_filter,
  state: "not_started", evidence: ""} + (if has("sprint") then {sprint} else {} end);
([.epics[].stories[].id]) as $existing
| ([$fragment.epics[]?.stories[]?]) as $new
| ($existing + [$new[].id]) as $ids
| ([$new[] | select((.id | text) and (.name | text) and (.title | text) and (.test_filter | text)
      and (.acceptance_criteria | type == "array" and length > 0) | not) | .id // "a story without id"]
    | map("\(.) needs id, name, title, test_filter and at least one acceptance criterion.")) as $incomplete
| ($ids | group_by(.) | map(select(length > 1) | "\(.[0]) is used more than once.")) as $duplicates
| ([$new[] | .id as $id | (.depends_on // [])[] | select(. as $dep | $ids | index($dep) | not)
      | "\($id) depends on \(.), which does not exist."]) as $unknown
| . as $current
| ([$fragment.epics[]? | select(.id as $id | [$current.epics[].id] | index($id) | not)
      | select(((.title | text) and has("sprint")) | not)
      | "New epic \(.id) needs a title and a sprint (a number, or null to park it)."]) as $untitled
| def repo_paths: type == "array" and all(.[]; type == "string" and length > 0 and (test("[*?\\[]|^/|(^|/)\\.\\.(/|$)") | not));
  ([$new[] | select((.owns // []) | repo_paths | not)
      | "\(.id) owns must be repo-relative paths without wildcards; end a directory with /."]
   + (if ($fragment.shared // []) | repo_paths then [] else ["shared must be repo-relative paths without wildcards; end a directory with /."] end)) as $bad_paths
| ($incomplete + $duplicates + $unknown + $untitled + $bad_paths) as $errors
| if ($errors | length) > 0 then fail($errors) else . end
| reduce ($fragment.epics // [])[] as $epic (.;
    if any(.epics[]; .id == $epic.id)
    then .epics |= map(if .id == $epic.id then .stories += [$epic.stories[]? | normalize] else . end)
    else .epics += [{id: $epic.id, title: $epic.title, sprint: $epic.sprint, summary: ($epic.summary // ""),
      stories: [$epic.stories[]? | normalize]}]
    end)
| .sprints = ((.sprints + ($fragment.sprints // [])) | unique_by(.sprint))
| if ($fragment.shared // []) | length > 0 then .shared = ((.shared // []) + $fragment.shared | unique) else . end
