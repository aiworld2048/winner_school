<?php

namespace Database\Seeders;

use App\Models\DictionaryEntry;
use Illuminate\Database\Seeder;

class DictionarySeeder extends Seeder
{
    public function run(): void
    {
        $entries = [
            ['Go', 'သွားသည်', 'I go to school every day.'],
            ['Read', 'ဖတ်သည်', 'We read an interesting story.'],
            ['Write', 'ရေးသည်', 'Please write your name clearly.'],
            ['Help', 'ကူညီသည်', 'Can you help me with my homework?'],
            ['Talk', 'ပြောသည်/စကားပြောသည်', 'They like to talk about movies.'],
            ['Study', 'စာကျက်သည်/လေ့လာသည်', 'We study English in the class.'],
            ['Draw', 'ဆွဲသည် (ပုံ)', 'She can draw beautiful pictures.'],
            ['Listen', 'နားထောင်သည်', 'Listen to your teacher carefully.'],
            ['Visit', 'သွားရောက်လည်ပတ်သည်', 'My family will visit the museum.'],
            ['Share', 'ခွဲဝေသည်/မျှဝေသည်', 'Please share your toys with your friends.'],
            ['Country', 'နိုင်ငံ', 'Myanmar is a beautiful country.'],
            ['Season', 'ရာသီဥတု', 'Summer is my favorite season.'],
            ['Market', 'ဈေး', 'We buy vegetables at the market.'],
            ['Holiday', 'ရုံးပိတ်ရက်/အားလပ်ရက်', 'We went on a holiday to the beach.'],
            ['Hobby', 'ဝါသနာ', 'My hobby is collecting stamps.'],
            ['Neighbor', 'အိမ်နီးချင်း', 'My neighbor is very kind.'],
            ['Lesson', 'သင်ခန်းစာ', 'We have a new lesson today.'],
            ['Village', 'ရွာ', 'He lives in a small village.'],
            ['Project', 'စီမံကိန်း/လုပ်ငန်း', 'We have to finish our school project.'],
            ['Mountain', 'တောင်', 'Mount Everest is a very high mountain.'],
            ['Friendly', 'ဖော်ရွေသော', 'The new student is very friendly.'],
            ['Different', 'ကွဲပြားသော/မတူညီသော', 'We have different kinds of pens.'],
            ['Exciting', 'စိတ်လှုပ်ရှားစရာကောင်းသော', 'The game was very exciting.'],
            ['Healthy', 'ကျန်းမာသော', 'Eating fruits keeps you healthy.'],
            ['Important', 'အရေးကြီးသော', 'This is an important meeting.'],
            ['Local', 'ဒေသဆိုင်ရာ/ဒေသခံ', 'We ate some local food.'],
            ['Careful', 'သတိထားသော', 'Be careful when crossing the road.'],
            ['Quiet', 'တိတ်ဆိတ်သော', 'The library is always quiet.'],
            ['Simple', 'ရိုးရှင်းသော', 'The problem has a simple solution.'],
            ['Polite', 'ယဉ်ကျေးသော', 'She is a very polite girl.'],
        ];

        foreach ($entries as [$english, $myanmar, $example]) {
            DictionaryEntry::updateOrCreate(
                ['english_word' => $english],
                ['myanmar_meaning' => $myanmar, 'example' => $example]
            );
        }
    }
}

