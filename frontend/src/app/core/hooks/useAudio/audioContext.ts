let audioContext: AudioContext | undefined;

export function getAudioContext() {
  if (!audioContext) {
    audioContext = new AudioContext();
  }
  return audioContext;
}

export function resumeAudioContext() {
  if (audioContext && audioContext.state === "suspended") {
    return audioContext.resume();
  }
}

export function suspendAudioContext() {
  if (audioContext && audioContext.state === "running") {
    return audioContext.suspend();
  }
}
