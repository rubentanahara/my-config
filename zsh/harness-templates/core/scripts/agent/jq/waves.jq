  . as $root
  | stories as $all
  | ($all | map(select(.state == "passing") | .id)) as $passing
  | {open: [$all[] | select((.state | IN($open_states[])) and .sprint != null)], skipped: []}
  | until((.open | map(.id)) as $ids | all(.open[]; (.depends_on - $passing - $ids) | length == 0);
      (.open | map(.id)) as $ids
      | [.open[] | select((.depends_on - $passing - $ids) | length > 0)] as $stuck
      | .skipped += [$stuck[] | "\(.id) waits on \((.depends_on - $passing - $ids) | join(", ")), which is blocked, parked, or waiting on one."]
      | .open -= $stuck)
  | .skipped as $skipped
  | .open as $open
  | [$open[] | .sprint as $sprint | .id as $id | .depends_on[] as $dep | $open[] | select(.id == $dep and .sprint > $sprint)
      | "\($id) (sprint \($sprint)) depends on \(.id), which is in later sprint \(.sprint)."] as $late
  | if ($late | length) > 0 then fail($late) else . end
  | ($root.shared // []) as $shared
  | {remaining: [$open[] | .sprint as $sprint | . + {after: [$open[] | select(.sprint < $sprint) | .id], claims: claims($shared)}],
     done: $passing, waves: [], notes: []}
  | until(.remaining | length == 0;
      .done as $done
      | (.remaining | map(select((.depends_on + .after - $done) | length == 0))) as $ready
      | if ($ready | length) == 0 then fail(["Dependency cycle among: \(.remaining | map(select((.depends_on - $done) | length > 0) | .id) | join(", "))"]) else . end
      | (reduce $ready[] as $story ({picked: [], notes: []};
          [.picked[] | select((.claims | length) == 0 or ($story.claims | length) == 0 or (overlap(.claims; $story.claims) | length) > 0)] as $clashes
          | if (.picked | length) == 0 or ($clashes | length) == 0 then .picked += [$story]
            elif ($story.claims | length) == 0 then .notes += [{id: $story.id, text: "\($story.id) runs alone: it has no owns."}]
            elif ($clashes[0].claims | length) == 0 then .notes += [{id: $story.id, text: "\($story.id) waits for \($clashes[0].id), which has no owns and runs alone."}]
            else .notes += [{id: $story.id, text: "\($story.id) waits for \($clashes[0].id): both own \(overlap($clashes[0].claims; $story.claims)[0])."}]
            end)) as $round
      | ($round.picked | map(.id)) as $wave
      | .waves += [$wave] | .done += $wave | .notes += $round.notes
      | .remaining |= map(select(.id as $id | $wave | index($id) | not)))
  | {waves, skipped: ($skipped + (.notes | unique_by(.id) | map(.text)))}
