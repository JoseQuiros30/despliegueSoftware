import json
import sys

service = json.load(sys.stdin)
status = service.get('status', {})
traffic = (status.get('trafficStatuses') or status.get('traffic') or
           service.get('trafficStatuses') or service.get('traffic', []))
previous = next((t.get('revisionName') or t.get('revision') for t in traffic
                 if t.get('percent') == 100 and (t.get('revisionName') or t.get('revision'))), None)
if not previous:
    previous = status.get('latestReadyRevisionName') or service.get('latestReadyRevision')
if not previous:
    raise SystemExit('No se encontró una revisión anterior en servicio')
print(previous.split('/')[-1])
