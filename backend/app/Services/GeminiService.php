<?php 

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
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

        $response = Http::timeout(60)
            ->withHeaders([
                'x-goog-api-key' => $apiKey,
            ])
            ->post(
                "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent",
                [
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
                ]
            );

        if ($response->failed()) {
            Log::error('Gemini API Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            throw new Exception('Gagal mendapatkan rekomendasi dari Gemini.');
        }

        $text = $response->json(
            'candidates.0.content.parts.0.text'
        );

        if (!$text) {
            throw new Exception('Respons Gemini kosong.');
        }

        $result = json_decode($text, true);

        if (!is_array($result) || !isset($result['itinerary'])) {
            throw new Exception('Format itinerary dari Gemini tidak valid.');
        }

        return $result;
    }
}
