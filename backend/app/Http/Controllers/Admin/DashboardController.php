<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function index()
    {
        $admin = Auth::user();
        return view('admin.dashboard', compact('admin'));
    }



    public function restoran()
    {
        $admin = Auth::user();
        return view('admin.restoran', compact('admin'));
    }
}
