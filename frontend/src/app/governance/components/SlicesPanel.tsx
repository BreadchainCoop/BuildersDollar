import { useMemo } from "react";
import { useQuery } from "react-query";

export function SlicesPanel() {
  const { data, error, isLoading } = useQuery(
    "slices",
    async () => {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_BREAD_API_URL}/slices`
      );
      return res.json();
    },
    {
      refetchInterval: 1000,
    }
  );
  // const totals = useMemo(() => {
  //   return data?.reduce(
  //     (acc, vote) => {
  //       console.log("\n\n-----", { vote });
  //       acc[vote.project_id] =
  //         acc[vote["project_id"]] + vote.value || vote.value;
  //       acc.count += 1;
  //       return acc;
  //     },
  //     { count: 0 } as Record<string, number>
  //   );
  // }, [data]);

  return (
    <div>
      <h2>slices</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
