import * as Sentry from "@sentry/react";
import { useEffect } from "react";

export function useSentry() {
  useEffect(() => {
    if (process.env.NEXT_PUBLIC_SENTRY_DSN)
      Sentry.init({
        dsn: "https://88428fa48e306d2d0b486226b7281b74@o4505884558360576.ingest.us.sentry.io/4506695825162240",

        tracesSampleRate: 1.0,

        // Set `tracePropagationTargets` to control for which URLs distributed tracing should be enabled
        tracePropagationTargets: ["localhost"],

        // Capture Replay for 10% of all sessions,
        // plus for 100% of sessions with an error
        replaysSessionSampleRate: 0.1,
        replaysOnErrorSampleRate: 1.0,
      });
  }, []);
}
