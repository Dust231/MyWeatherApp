#ifndef SPEECHHELPER_H
#define SPEECHHELPER_H

#include <QObject>
#include <QTextToSpeech>

class SpeechHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool speaking READ isSpeaking NOTIFY speakingChanged)

public:
    explicit SpeechHelper(QObject *parent = nullptr);

    bool isSpeaking() const;

    Q_INVOKABLE void speak(const QString &text);
    Q_INVOKABLE void stop();

signals:
    void speakingChanged();

private slots:
    void onStateChanged(QTextToSpeech::State state);

private:
    QTextToSpeech *m_speech;
};

#endif // SPEECHHELPER_H
