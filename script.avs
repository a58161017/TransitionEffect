LoadPlugIn("TransAll.dll")
LoadPlugIn("ffms2.dll")
Import("FFMS2.avsi")
file1="c_aac_vdo1.mp4"
file2="c_aac_vdo2.mp4"
video1=FFmpegSource2(file1, atrack = -1)
video2=FFmpegSource2(file2, atrack = -1).assumeFPS(video1)
trans_duration=FrameRate(video1)*1
Left = video1.Trim(0, FrameCount(video1) - int(trans_duration))
S_Left = video1.Trim(FrameCount(video1) - int(trans_duration), FrameCount(video1))
Right=video2.Trim(int(trans_duration), FrameCount(video2))
S_Right=video2.Trim(0, int(trans_duration))
t_video=KillAudio(TransPush(S_Left, S_Right, FrameCount(S_Left + S_Right) / 2, "left"))
t_audio=BlankClip(length=FrameCount(t_video), audio_rate=44100, channels=1, sample_type="16bit")
Left+Audiodub(t_video, t_audio)+Right
