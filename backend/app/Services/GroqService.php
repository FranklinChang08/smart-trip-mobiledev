<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class GroqService
{
    public function generateItinerary(array $data): array
    {
        $apiKey = config('services.groq.key');
        $model = config('services.groq.model');

        if (!$apiKey) {
            throw new Exception('Groq API Key belum dikonfigurasi.');
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

        $modelsToTry = array_unique(array_filter([$model, 'qwen/qwen3.8-27b', 'openai/gpt-oss-120b']));
        $lastException = null;

        foreach ($modelsToTry as $currentModel) {
            try {
                $response = Http::connectTimeout(8)
                    ->timeout(20)
                    ->withToken($apiKey)
                    ->post(
                        'https://api.groq.com/openai/v1/chat/completions',
                        [
                            'model' => $currentModel,
                            'messages' => [
                                [
                                    'role' => 'user',
                                    'content' => $prompt,
                                ],
                            ],
                            'temperature' => 0.3,
                            'response_format' => [
                                'type' => 'json_object',
                            ],
                        ]
                    );

                if ($response->failed()) {
                    Log::warning("Groq API model {$currentModel} failed", [
                        'status' => $response->status(),
                        'response' => $response->json(),
                    ]);
                    continue;
                }

                $text = $response->json('choices.0.message.content');

                if (!is_string($text) || trim($text) === '') {
                    continue;
                }

                $result = json_decode($text, true);

                if (
                    !is_array($result) ||
                    !isset($result['itinerary']) ||
                    !is_array($result['itinerary'])
                ) {
                    continue;
                }

                Log::info("Groq berhasil menghasilkan itinerary dengan model {$currentModel}");

                return $result;
            } catch (Exception $e) {
                $lastException = $e;
                Log::warning("Groq exception with model {$currentModel}: " . $e->getMessage());
            }
        }

        throw new Exception('Gagal mendapatkan rekomendasi dari Groq.');
    }
}