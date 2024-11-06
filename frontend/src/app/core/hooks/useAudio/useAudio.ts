import { useEffect, useState } from "react";
import { getAudioContext } from "./audioContext";

export function useAudio({ src }: { src: string }) {
  const [audioBuffer, setAudioBuffer] = useState<AudioBuffer | null>(null);

  useEffect(() => {
    async function fetchAudio() {
      const audioContext = getAudioContext();
      if (!audioContext) return;
      const arrayBuffer = await fetch(src).then((res) => res.arrayBuffer());
      audioContext
        .decodeAudioData(arrayBuffer)
        .then((audioBuffer) => {
          setAudioBuffer(audioBuffer);
        })
        .catch((err): void => {
          console.log({ err });
        });
    }
    fetchAudio();
  }, [src]);

  async function playSound() {
    if (!audioBuffer) return;
    const audioContext = getAudioContext();
    const src = audioContext.createBufferSource();
    const gain = audioContext.createGain();
    const now = audioContext.currentTime;
    if (audioContext.state === "suspended") {
      await audioContext.resume();
    }
    src.buffer = audioBuffer;
    src.loop = false;
    src.connect(gain);
    gain.connect(audioContext.destination);
    src.start(now);
    gain.gain.setValueAtTime(1, now);
    gain.gain.setValueAtTime(1, now + 0.4);
    gain.gain.linearRampToValueAtTime(0, now + 1.2);

    // console.log("playing sound");
    // console.log("playing sound", audioContext.state);
    // if (audioContext.state === "suspended") {
    //   await audioContext.resume();
    //   console.log("ctx state after:", audioContext.state);
    //   source.onended = () => initSource(audioBuffer);
    //   return;
    // }
    // source.start();
    // source.onended = () => initSource(audioBuffer);
  }

  return { playSound };
}
