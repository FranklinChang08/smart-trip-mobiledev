<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Client\ConnectionException;
use Exception;

class GeminiService
{

    public function generateItinerary(array $data): array
    {
        $apiKey = config('services.gemini.key');
        $model = config('services.gemini.model');

        if (!$apiKey) {
            throw new Exception('Gemini API Key belum dikonfigurasi.');
        }

        if (!$model) {
            throw new Exception('Gemini Model belum dikonfigurasi.');
        }

        $prompt = "
        Kamu adalah AI travel planner untuk SmartTrip.
        Buat itinerary perjalanan berdasarkan data berikut:
        " . json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "

        Pilih destinasi hanya dari data yang diberikan.
        Jangan membuat ID destinasi sendiri.

        Kembalikan hasil dalam format JSON:
        {
            \"itinerary\": [
                {
                    \"day\": 1,
                    \"items\": [
                        {
                            \"destination_id\": \"ID_DESTINASI\",
                            \"type\": \"wisata\",
                            \"start_time\": \"09:00\",
                            \"end_time\": \"11:00\"
                        }
                    ]
                }
            ]
        }
    ";

        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent";

        $startTime = microtime(true);

        try {
            $response = Http::connectTimeout(15)
                ->timeout(180)
                ->withHeaders([
                    'x-goog-api-key' => $apiKey,
                ])
                ->post($url, [
                    'contents' => [
                        [
                            'parts' => [
                                ['text' => $prompt],
                            ],
                        ],
                    ],
                    'generationConfig' => [
                        'responseMimeType' => 'application/json',
                    ],
                ]);

            $duration = round(microtime(true) - $startTime, 2);

            Log::info('Gemini Request Duration', [
                'duration' => $duration,
                'status' => $response->status(),
            ]);

        } catch (ConnectionException $e) {
            Log::error('Gemini Connection Error', [
                'message' => $e->getMessage(),
                'duration' => round(microtime(true) - $startTime, 2),
            ]);

            throw new Exception('Tidak dapat terhubung ke Gemini API.');
        }

        if ($response->failed()) {
            Log::error('Gemini API Failed', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            throw new Exception('Gagal mendapatkan rekomendasi dari Gemini.');
        }

        $text = $response->json('candidates.0.content.parts.0.text');

        if (!$text) {
            Log::error('Gemini Empty Response', [
                'response' => $response->json(),
            ]);

            throw new Exception('Respons Gemini kosong.');
        }

        $result = json_decode($text, true);

        if (
            !is_array($result) ||
            !isset($result['itinerary']) ||
            !is_array($result['itinerary'])
        ) {
            Log::error('Gemini Invalid JSON Response', [
                'response_text' => $text,
                'json_error' => json_last_error_msg(),
            ]);

            throw new Exception('Format itinerary dari Gemini tidak valid.');
        }

        return $result;
    }

}