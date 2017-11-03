# TransitionEffect
利用Avisynth合成影片，並且使用TransAll的轉場特效，最後ffmpeg使用進行編碼

## Environment And Tools
作業系統:Windows
FFmpeg:ffmpeg-3.4-win32-static(注意:一定要win32版，TransAll只有x86版本)
  下載 https://www.ffmpeg.org/download.html#build-windows
Avisynth:AviSynth_260(AviSynth.dll、DevIL.dll)，可以編輯影片的工具
  下載 https://sourceforge.net/projects/avisynth2/
FFMS2:ffms2-2.23.1-msvc(x86:ffms2.dll、FFMS2.avsi)，可以讓avisynth載入mp4檔
  下載 https://github.com/FFMS/ffms2/releases
TransAll:TransAll.dll，Avisynth的一個插件，可以讓影片產生轉場特效
  參考 http://www.avisynth.nl/users/vcmohan/TransAll/docs/index.html
  無載點，網路上說TransAll.dll存在AviSynth+，但是，沒有任何發現，所以google隨便下載
  
PS:只要有ffmpeg.exe、AviSynth.dll、DevIL.dll、ffms2.dll、FFMS2.avsi、TransAll.dll以上檔案，便可以直接移植到其他地方執行

## Video Convert
影片來源H264、解析度需一致，音頻來源PCM，先用ffmpeg轉AAC且統一SampleRate:44100、Channel:1、Bitrate:128k
ffmpeg -y -i vdo1.mp4 -c:v copy -c:a aac -strict experimental -ar 44100 -ac 1 -ab 128k aac_vdo1.mp4
ffmpeg -y -i vdo2.mp4 -c:v copy -c:a aac -strict experimental -ar 44100 -ac 1 -ab 128k aac_vdo2.mp4

用ffmpeg影片長度切割至整數(最小單位:秒)，不切割影片Avisynth無法讀取檔案(?)
ffmpeg -i aac_vdo1.mp4 -ss 00:00:00 -to hh:mm:ss -c copy c_aac_vdo1.mp4
ffmpeg -i aac_vdo2.mp4 -ss 00:00:00 -to hh:mm:ss -c copy c_aac_vdo2.mp4

## Avisynth Script
創建一個Avisynth腳本為script.avs，以下為內容(#表示註解):
#由於轉場特效會使audio部分有問題，所以下方會將video切成需要轉場和不需要轉場的部分
LoadPlugIn("TransAll.dll")
LoadPlugIn("ffms2.dll")
Import("FFMS2.avsi")
file1="c_aac_vdo1.mp4"
file2="c_aac_vdo2.mp4"
video1=FFmpegSource2(file1, atrack = -1)
video2=FFmpegSource2(file2, atrack = -1).assumeFPS(video1)                                        #利用assumeFPS調整video2的fps
trans_duration=FrameRate(video1)*1                                                                #最後面的1表示轉長時間1秒
Left = video1.Trim(0, FrameCount(video1) - int(trans_duration))                                   #切割video1不需要轉場的部分
S_Left = video1.Trim(FrameCount(video1) - int(trans_duration), FrameCount(video1))                #切割video1需要轉場的部分
Right=video2.Trim(int(trans_duration), FrameCount(video2))                                        #切割video2不需要轉場的部分
S_Right=video2.Trim(0, int(trans_duration))                                                       #切割video2需要轉場的部分
t_video=KillAudio(TransPush(S_Left, S_Right, FrameCount(S_Left + S_Right) / 2, "left"))           #使用轉場特效TransPush()，並且移除audio
t_audio=BlankClip(length=FrameCount(t_video), audio_rate=44100, channels=1, sample_type="16bit")  #產生靜音給轉場的部分
Left+Audiodub(t_video, t_audio)+Right                                                             #Audiodub()可以將影像和聲音結合

## Encode Script
ffmpeg -y -i script.avs -c:v libx264 -c:a aac -strict experimental -ar 44100 -ac 1 -ab 128k output.mp4
