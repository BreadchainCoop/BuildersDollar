import Button from "../Button";

export function AddTokens({
  handleAddToken,
}: {
  handleAddToken: (tokenType: "BREAD" | "DAI") => void;
}) {
  return (
    <div className="p-2 pt-12">
      <div className="mb-8 text-breadgray-light-grey">Add tokens to wallet</div>
      <div className="flex gap-4">
        <Button onClick={() => handleAddToken("BREAD")} disabled={false}>
          BREAD
        </Button>
      </div>
    </div>
  );
}

export default AddTokens;
