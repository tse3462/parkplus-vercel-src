import { Badge } from "@/components/ui/badge";
import type { ParkingSession } from "@/lib/parking/types";

export function StatusPill({ session }: { session: ParkingSession }) {
  if (session.status === "closed") {
    return <Badge variant="closed">Kapalı · ödendi</Badge>;
  }
  if (session.penaltyFee > 0) {
    return <Badge variant="warn">Açık · ceza</Badge>;
  }
  return <Badge variant="open">Açık · ödenmedi</Badge>;
}
