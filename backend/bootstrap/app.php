<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )

    ->withMiddleware(function (Middleware $middleware): void {
    })

    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn(Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $exceptions->render(function (\Illuminate\Database\QueryException $e, Request $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                $isConnectionError = in_array($e->getCode(), [2002, 1045, 'HY000']);
                if ($isConnectionError) {
                    return response()->json([
                        'message' => 'Tidak dapat terhubung ke server database. Silakan pastikan database aktif atau coba beberapa saat lagi.',
                    ], 503);
                }
                if (config('app.debug')) {
                    return response()->json([
                        'message' => $e->getMessage(),
                    ], 500);
                }
                return response()->json([
                    'message' => 'Terjadi kesalahan pada database.',
                ], 500);
            }
        });
    })->create();
