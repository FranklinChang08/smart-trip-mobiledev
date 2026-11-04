<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class OpenRouterService
{
    public function generateItinerary(array $data): array
    {
        $apiKey = config('services.openrouter.key');
        $model = config('services.openrouter.model');

        if (!$apiKey) {
            throw new Exception('OpenRouter API Key belum dikonfigurasi.');
        }

        $prompt = "
            Kamu adalah AI travel planner untuk SmartTrip.

            Buat itinerary perjalanan berdasarkan data berikut:

            " . json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "

            Pilih destinasi hanya dari data yang diberikan.
            Jangan membuat ID destinasi sendiri.

            Kembalikan hanya JSON dengan format:

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

        $response = Http::connectTimeout(15)
            ->timeout(180)
            ->withToken($apiKey)
            ->withHeaders([
                'HTTP-Referer' => config('app.url'),
                'X-OpenRouter-Title' => 'SmartTrip',
            ])
            ->post(
                'https://openrouter.ai/api/v1/chat/completions',
                [
                    'model' => $model,
                    'messages' => [
                        [
                            'role' => 'user',
                            'content' => $prompt,
                        ],
                    ],
                    'temperature' => 0.3,
                ]
            );

        if ($response->failed()) {
            Log::error('OpenRouter API Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            throw new Exception(
                'Gagal mendapatkan rekomendasi dari OpenRouter.'
            );
        }

        $text = $response->json('choices.0.message.content');

        if (!is_string($text) || trim($text) === '') {
            throw new Exception('Respons OpenRouter kosong.');
        }

        // Membersihkan kemungkinan markdown code fence.
        $text = preg_replace('/^```(?:json)?\s*|\s*```$/i', '', trim($text));

        $result = json_decode($text, true);

        if (
            !is_array($result) ||
            !isset($result['itinerary']) ||
            !is_array($result['itinerary'])
        ) {
            throw new Exception('Format itinerary OpenRouter tidak valid.');
        }

        Log::info('OpenRouter berhasil menghasilkan itinerary');

        return $result;
    }
}
