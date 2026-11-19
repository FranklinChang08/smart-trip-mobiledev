<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode Verifikasi OTP SmartTrip</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background-color: #f8fafc;
            color: #334155;
            margin: 0;
            padding: 24px;
        }
        .container {
            max-width: 520px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        .header {
            background-color: #00685F;
            padding: 24px 20px;
            text-align: center;
            color: #ffffff;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 800;
            letter-spacing: 1px;
        }
        .header p {
            margin: 6px 0 0 0;
            font-size: 13px;
            opacity: 0.9;
        }
        .content {
            padding: 32px 28px;
            text-align: center;
        }
        .greeting {
            font-size: 18px;
            font-weight: 700;
            color: #111827;
            margin-bottom: 12px;
        }
        .instruction {
            font-size: 14px;
            line-height: 1.6;
            color: #4b5563;
            margin-bottom: 24px;
        }
        .otp-box {
            display: inline-block;
            background-color: #f1f5f9;
            border: 2px dashed #00685F;
            border-radius: 12px;
            padding: 14px 28px;
            margin: 10px 0 24px 0;
        }
        .otp-code {
            font-size: 32px;
            font-weight: 800;
            letter-spacing: 8px;
            color: #BA4D0C;
            font-family: 'Courier New', monospace;
        }
        .timer-info {
            font-size: 13px;
            color: #64748b;
            margin-bottom: 20px;
        }
        .warning {
            font-size: 12px;
            color: #94a3b8;
            line-height: 1.5;
            border-top: 1px solid #f1f5f9;
            padding-top: 18px;
        }
        .footer {
            background-color: #f8fafc;
            padding: 16px;
            text-align: center;
            font-size: 12px;
            color: #94a3b8;
            border-top: 1px solid #e2e8f0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SMARTTRIP BATAM</h1>
            <p>● 1.1301° N, 104.0529° E</p>
        </div>
        <div class="content">
            <div class="greeting">Halo, {{ $user->nama_pengguna ?? 'Wisatawan' }}!</div>
            <div class="instruction">
                Kami menerima permintaan untuk mengatur ulang kata sandi akun SmartTrip Anda. Gunakan kode verifikasi (OTP) berikut untuk melanjutkan:
            </div>
            <div class="otp-box">
                <span class="otp-code">{{ $otp }}</span>
            </div>
            <div class="timer-info">
                 Kode verifikasi ini berlaku selama <strong>15 menit</strong>.
            </div>
            <div class="warning">
                Jangan berikan kode ini kepada siapa pun termasuk pihak SmartTrip. Jika Anda tidak merasa melakukan permintaan ini, abaikan email ini.
            </div>
        </div>
        <div class="footer">
            &copy; {{ date('Y') }} SmartTrip Batam. Data dan privasi Anda terenkripsi aman.
        </div>
    </div>
</body>
</html>

