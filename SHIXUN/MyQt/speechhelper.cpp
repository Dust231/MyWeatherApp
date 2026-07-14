#include "speechhelper.h"
#include <QDebug>

SpeechHelper::SpeechHelper(QObject *parent)
    : QObject(parent), m_speech(new QTextToSpeech(this))
{
    // 设置中文语音（如果系统支持）
    const QVector<QVoice> voices = m_speech->availableVoices();
    for (const QVoice &voice : voices) {
        if (voice.name().contains("zh") || voice.name().contains("Huihui") ||
            voice.name().contains("Yaoyao") || voice.name().contains("Kangkang")) {
            m_speech->setVoice(voice);
            break;
        }
    }
    m_speech->setRate(0.0);     // 正常语速
    m_speech->setPitch(0.0);    // 正常音调
    connect(m_speech, &QTextToSpeech::stateChanged, this, &SpeechHelper::onStateChanged);
}

bool SpeechHelper::isSpeaking() const
{
    return m_speech->state() == QTextToSpeech::Speaking;
}

void SpeechHelper::speak(const QString &text)
{
    if (text.isEmpty()) return;
    qDebug() << "[SpeechHelper] speak:" << text;
    // 如果正在播报，先停止
    if (m_speech->state() == QTextToSpeech::Speaking) {
        m_speech->stop();
    }
    m_speech->say(text);
}

void SpeechHelper::stop()
{
    m_speech->stop();
}

void SpeechHelper::onStateChanged(QTextToSpeech::State state)
{
    qDebug() << "[SpeechHelper] state changed:" << state;
    emit speakingChanged();
}
