import Foundation

/// Static dummy data for the POC. In a real app this would come from a backend.
enum SampleContent {

    static let user = User(
        id: "u-1001",
        name: "陳大文",
        englishName: "Tom Chan",
        grade: "Primary 5",
        school: "Hong Kong Primary School",
        avatarColorHex: "4F8EF7"
    )

    // MARK: - Chapter 1 — Healthy Living (flagship P5 sample)

    private static let chapter1Vocabulary: [VocabularyItem] = [
        VocabularyItem(
            id: "c1-v1", word: "healthy", phonetic: "/ˈhel.θi/", partOfSpeech: "adjective",
            meaning: "健康的",
            definition: "good for your body and mind",
            example: "Eating fruit keeps you healthy."
        ),
        VocabularyItem(
            id: "c1-v2", word: "exercise", phonetic: "/ˈek.sə.saɪz/", partOfSpeech: "noun / verb",
            meaning: "運動；鍛煉",
            definition: "activity that makes your body strong",
            example: "I do exercise every morning."
        ),
        VocabularyItem(
            id: "c1-v3", word: "balanced diet", phonetic: "/ˌbæl.ənst ˈdaɪ.ət/", partOfSpeech: "noun phrase",
            meaning: "均衡飲食",
            definition: "eating different kinds of healthy food",
            example: "A balanced diet helps you grow."
        ),
        VocabularyItem(
            id: "c1-v4", word: "habit", phonetic: "/ˈhæb.ɪt/", partOfSpeech: "noun",
            meaning: "習慣",
            definition: "something you do often",
            example: "Brushing your teeth is a good habit."
        ),
        VocabularyItem(
            id: "c1-v5", word: "enough", phonetic: "/ɪˈnʌf/", partOfSpeech: "adjective / adverb",
            meaning: "足夠的",
            definition: "as much as you need",
            example: "Get enough sleep every night."
        ),
        VocabularyItem(
            id: "c1-v6", word: "regularly", phonetic: "/ˈreɡ.jə.lə.li/", partOfSpeech: "adverb",
            meaning: "定期地；規律地",
            definition: "often and at the same times",
            example: "We exercise regularly."
        ),
        VocabularyItem(
            id: "c1-v7", word: "vegetables", phonetic: "/ˈvedʒ.tə.bəlz/", partOfSpeech: "noun (plural)",
            meaning: "蔬菜",
            definition: "plants we eat, like carrots and broccoli",
            example: "Vegetables are full of vitamins."
        ),
        VocabularyItem(
            id: "c1-v8", word: "energy", phonetic: "/ˈen.ə.dʒi/", partOfSpeech: "noun",
            meaning: "能量；精力",
            definition: "the power to move, play and think",
            example: "Breakfast gives me energy."
        )
    ]

    private static let chapter1Grammar: [GrammarConcept] = [
        GrammarConcept(
            id: "c1-g1",
            title: "Adverbs of frequency",
            explanation: "We use always, usually, sometimes and never to say how often we do something.",
            rule: "Put the adverb before the main verb, but after the verb 'to be'.",
            examples: [
                "I always brush my teeth before bed.",
                "She usually walks to school.",
                "He is never late for class.",
                "We sometimes play basketball after school."
            ]
        ),
        GrammarConcept(
            id: "c1-g2",
            title: "Present simple for routines",
            explanation: "We use the present simple to talk about habits and things we do regularly.",
            rule: "Add -s or -es to the verb for he / she / it.",
            examples: [
                "Tom eats breakfast at seven o'clock.",
                "She goes swimming every weekend.",
                "I do not eat too many sweets.",
                "Do you drink enough water?"
            ]
        )
    ]

    private static let chapter1Exercises: [MCQuestion] = [
        MCQuestion(
            id: "c1-e1",
            prompt: "She ___ to school every day.",
            options: ["walk", "walks", "walking", "walked"],
            correctIndex: 1,
            explanation: "For 'she' in the present simple, we add -s to the verb: 'she walks'."
        ),
        MCQuestion(
            id: "c1-e2",
            prompt: "I ___ eat junk food because it is bad for my health.",
            options: ["always", "usually", "sometimes", "never"],
            correctIndex: 3,
            explanation: "Junk food is unhealthy, so we should 'never' eat it."
        ),
        MCQuestion(
            id: "c1-e3",
            prompt: "Which sentence is correct?",
            options: [
                "He always brushes his teeth.",
                "He brushes always his teeth.",
                "Always he brushes his teeth.",
                "He brushes his always teeth."
            ],
            correctIndex: 0,
            explanation: "The adverb of frequency goes before the main verb: 'always brushes'."
        ),
        MCQuestion(
            id: "c1-e4",
            prompt: "My brother ___ late for school.",
            options: ["never is", "is never", "never", "is never be"],
            correctIndex: 1,
            explanation: "After the verb 'to be' we put the adverb: 'is never'."
        ),
        MCQuestion(
            id: "c1-e5",
            prompt: "We should eat ___ vegetables to stay healthy.",
            options: ["much", "a lot of", "a little", "many"],
            correctIndex: 1,
            explanation: "'Vegetables' is a countable plural noun, so we use 'a lot of'."
        )
    ]

    private static let chapter1Reading = ReadingPassage(
        id: "c1-r1",
        title: "Tom's Healthy Day",
        paragraphs: [
            "Tom is a Primary 5 student in Hong Kong. He has many good habits. Every morning, he gets up at seven o'clock and eats a healthy breakfast. He usually has oatmeal, an egg and a glass of milk. Breakfast gives him energy for the day.",
            "After school, Tom always does exercise. He plays basketball with his friends in the park. Sometimes he goes swimming with his father at the weekend. Tom does not eat too many sweets because they are bad for his teeth.",
            "Before bed, Tom usually reads a storybook. He never stays up late because he needs enough sleep. His mother says a balanced diet and regular exercise keep him healthy and strong."
        ],
        questions: [
            MCQuestion(
                id: "c1-r1-q1",
                prompt: "What time does Tom get up?",
                options: ["Six o'clock", "Seven o'clock", "Eight o'clock", "Nine o'clock"],
                correctIndex: 1,
                explanation: "The passage says 'he gets up at seven o'clock'."
            ),
            MCQuestion(
                id: "c1-r1-q2",
                prompt: "What does Tom usually eat for breakfast?",
                options: [
                    "Oatmeal, an egg and milk",
                    "Bread and coffee",
                    "Rice and fish",
                    "Sweets and juice"
                ],
                correctIndex: 0,
                explanation: "The passage says he has 'oatmeal, an egg and a glass of milk'."
            ),
            MCQuestion(
                id: "c1-r1-q3",
                prompt: "What does breakfast give Tom?",
                options: ["Money", "Energy", "Sweets", "Homework"],
                correctIndex: 1,
                explanation: "The passage says 'Breakfast gives him energy for the day'."
            ),
            MCQuestion(
                id: "c1-r1-q4",
                prompt: "How often does Tom do exercise after school?",
                options: ["Never", "Sometimes", "Always", "Rarely"],
                correctIndex: 2,
                explanation: "The passage says 'Tom always does exercise' after school."
            ),
            MCQuestion(
                id: "c1-r1-q5",
                prompt: "What does Tom never do?",
                options: [
                    "Read a storybook",
                    "Play basketball",
                    "Stay up late",
                    "Eat breakfast"
                ],
                correctIndex: 2,
                explanation: "The passage says 'He never stays up late'."
            )
        ]
    )

    // MARK: - Chapter 2 — Protecting Our Environment

    private static let chapter2Vocabulary: [VocabularyItem] = [
        VocabularyItem(
            id: "c2-v1", word: "environment", phonetic: "/ɪnˈvaɪ.rən.mənt/", partOfSpeech: "noun",
            meaning: "環境",
            definition: "the natural world around us",
            example: "We must protect the environment."
        ),
        VocabularyItem(
            id: "c2-v2", word: "recycle", phonetic: "/ˌriːˈsaɪ.kəl/", partOfSpeech: "verb",
            meaning: "回收；循環再用",
            definition: "to use old things to make new things",
            example: "We recycle paper and plastic bottles."
        ),
        VocabularyItem(
            id: "c2-v3", word: "reduce", phonetic: "/rɪˈdjuːs/", partOfSpeech: "verb",
            meaning: "減少",
            definition: "to make something smaller or less",
            example: "We should reduce the amount of rubbish we make."
        ),
        VocabularyItem(
            id: "c2-v4", word: "reuse", phonetic: "/ˌriːˈjuːz/", partOfSpeech: "verb",
            meaning: "重用",
            definition: "to use something again",
            example: "I reuse my water bottle every day."
        ),
        VocabularyItem(
            id: "c2-v5", word: "pollution", phonetic: "/pəˈluː.ʃən/", partOfSpeech: "noun",
            meaning: "污染",
            definition: "dirty air, water or land",
            example: "Air pollution is bad for our health."
        ),
        VocabularyItem(
            id: "c2-v6", word: "plastic", phonetic: "/ˈplæs.tɪk/", partOfSpeech: "noun / adjective",
            meaning: "塑膠",
            definition: "a material used to make bottles and bags",
            example: "Plastic bags can harm sea animals."
        )
    ]

    private static let chapter2Grammar: [GrammarConcept] = [
        GrammarConcept(
            id: "c2-g1",
            title: "Imperatives",
            explanation: "We use imperatives to give instructions or advice.",
            rule: "Start with the base form of the verb. For negatives, use 'Don't' before the verb.",
            examples: [
                "Turn off the lights when you leave.",
                "Don't throw rubbish on the ground.",
                "Save water when you brush your teeth."
            ]
        ),
        GrammarConcept(
            id: "c2-g2",
            title: "should / shouldn't",
            explanation: "We use 'should' to give advice and 'shouldn't' to say something is a bad idea.",
            rule: "should / shouldn't + base form of the verb.",
            examples: [
                "We should recycle our rubbish.",
                "You shouldn't waste paper.",
                "Everyone should care for the Earth."
            ]
        )
    ]

    private static let chapter2Exercises: [MCQuestion] = [
        MCQuestion(
            id: "c2-e1",
            prompt: "___ the tap while you brush your teeth.",
            options: ["Turning off", "Turn off", "Turned off", "To turn off"],
            correctIndex: 1,
            explanation: "Imperatives start with the base form: 'Turn off'."
        ),
        MCQuestion(
            id: "c2-e2",
            prompt: "You ___ throw rubbish into the sea.",
            options: ["should", "shouldn't", "don't", "must to"],
            correctIndex: 1,
            explanation: "Throwing rubbish into the sea is harmful, so we use 'shouldn't'."
        ),
        MCQuestion(
            id: "c2-e3",
            prompt: "We can ___ old jars to store things.",
            options: ["reuse", "reusing", "reused", "to reuse"],
            correctIndex: 0,
            explanation: "After the modal 'can' we use the base form: 'reuse'."
        ),
        MCQuestion(
            id: "c2-e4",
            prompt: "Which sentence gives good advice?",
            options: [
                "Don't waste paper.",
                "Wasting paper is fun.",
                "You should waste paper.",
                "Throw paper everywhere."
            ],
            correctIndex: 0,
            explanation: "'Don't waste paper' is good advice for the environment."
        )
    ]

    private static let chapter2Reading = ReadingPassage(
        id: "c2-r1",
        title: "Saving Our Beautiful Earth",
        paragraphs: [
            "The Earth is our home, so we must take care of it. Sadly, pollution is hurting our environment. Dirty air, water and land make life difficult for people, animals and plants.",
            "There are many simple things we can do to help. We can reduce the rubbish we make, reuse things like bottles and bags, and recycle paper, glass and metal. When we do these three things, less rubbish goes to the landfill.",
            "At school, students can turn off the lights when they leave the classroom. They can also bring their own water bottles instead of buying plastic ones. Small actions, when done by many people, can make a big difference to our planet."
        ],
        questions: [
            MCQuestion(
                id: "c2-r1-q1",
                prompt: "What is hurting our environment?",
                options: ["Pollution", "Recycling", "Plants", "The sun"],
                correctIndex: 0,
                explanation: "The passage says 'pollution is hurting our environment'."
            ),
            MCQuestion(
                id: "c2-r1-q2",
                prompt: "What are the three things we can do to reduce rubbish?",
                options: [
                    "Reduce, reuse and recycle",
                    "Buy, use and throw",
                    "Wash, dry and fold",
                    "Read, write and draw"
                ],
                correctIndex: 0,
                explanation: "The passage lists 'reduce, reuse and recycle'."
            ),
            MCQuestion(
                id: "c2-r1-q3",
                prompt: "What can students do when they leave the classroom?",
                options: [
                    "Turn off the lights",
                    "Throw away paper",
                    "Buy plastic bottles",
                    "Leave the tap running"
                ],
                correctIndex: 0,
                explanation: "The passage says students can 'turn off the lights'."
            ),
            MCQuestion(
                id: "c2-r1-q4",
                prompt: "Why should students bring their own water bottles?",
                options: [
                    "To save money on drinks",
                    "To avoid buying plastic ones",
                    "Because bottles are heavy",
                    "Because the teacher says so"
                ],
                correctIndex: 1,
                explanation: "The passage says they can bring their own bottles 'instead of buying plastic ones'."
            ),
            MCQuestion(
                id: "c2-r1-q5",
                prompt: "What is the main message of the passage?",
                options: [
                    "Pollution is good for the Earth",
                    "Small actions can make a big difference",
                    "Only adults can help the planet",
                    "Rubbish should go to the sea"
                ],
                correctIndex: 1,
                explanation: "The passage ends by saying small actions 'can make a big difference'."
            )
        ]
    )

    // MARK: - Chapter 3 — Festivals and Celebrations

    private static let chapter3Vocabulary: [VocabularyItem] = [
        VocabularyItem(
            id: "c3-v1", word: "celebrate", phonetic: "/ˈsel.ə.breɪt/", partOfSpeech: "verb",
            meaning: "慶祝",
            definition: "to do something special for a happy event",
            example: "We celebrate Chinese New Year with our family."
        ),
        VocabularyItem(
            id: "c3-v2", word: "festival", phonetic: "/ˈfes.tɪ.vəl/", partOfSpeech: "noun",
            meaning: "節日",
            definition: "a special day or time of celebration",
            example: "Mid-Autumn Festival is in autumn."
        ),
        VocabularyItem(
            id: "c3-v3", word: "lantern", phonetic: "/ˈlæn.tən/", partOfSpeech: "noun",
            meaning: "燈籠",
            definition: "a light inside a paper or glass cover",
            example: "Children carry colourful lanterns."
        ),
        VocabularyItem(
            id: "c3-v4", word: "traditional", phonetic: "/trəˈdɪʃ.ən.əl/", partOfSpeech: "adjective",
            meaning: "傳統的",
            definition: "done in the way of the past",
            example: "We wear traditional clothes at the festival."
        ),
        VocabularyItem(
            id: "c3-v5", word: "decorate", phonetic: "/ˈdek.ə.reɪt/", partOfSpeech: "verb",
            meaning: "裝飾",
            definition: "to make something look nice with colours or objects",
            example: "We decorate our house with red paper."
        ),
        VocabularyItem(
            id: "c3-v6", word: "reunion", phonetic: "/ˌriːˈjuː.njən/", partOfSpeech: "noun",
            meaning: "團聚",
            definition: "when family or friends meet again",
            example: "We have a family reunion dinner."
        )
    ]

    private static let chapter3Grammar: [GrammarConcept] = [
        GrammarConcept(
            id: "c3-g1",
            title: "Past simple (regular verbs)",
            explanation: "We use the past simple to talk about finished actions in the past.",
            rule: "Add -ed to regular verbs. For verbs ending in -e, just add -d.",
            examples: [
                "We decorated the house yesterday.",
                "She celebrated her birthday last week.",
                "They played games at the festival."
            ]
        ),
        GrammarConcept(
            id: "c3-g2",
            title: "Prepositions of time (in / on / at)",
            explanation: "We use different prepositions to talk about time.",
            rule: "Use 'in' for months and years, 'on' for days and dates, 'at' for clock times.",
            examples: [
                "Chinese New Year is in February.",
                "The party is on Monday.",
                "The show starts at eight o'clock."
            ]
        )
    ]

    private static let chapter3Exercises: [MCQuestion] = [
        MCQuestion(
            id: "c3-e1",
            prompt: "Last year, we ___ the Mid-Autumn Festival at the park.",
            options: ["celebrate", "celebrated", "celebrating", "celebrates"],
            correctIndex: 1,
            explanation: "'Last year' is the past, so we use the past simple: 'celebrated'."
        ),
        MCQuestion(
            id: "c3-e2",
            prompt: "The party is ___ Saturday.",
            options: ["in", "on", "at", "to"],
            correctIndex: 1,
            explanation: "We use 'on' for days of the week."
        ),
        MCQuestion(
            id: "c3-e3",
            prompt: "We ___ our house with lanterns last night.",
            options: ["decorate", "decorates", "decorated", "decorating"],
            correctIndex: 2,
            explanation: "'Last night' is the past, so we use 'decorated'."
        ),
        MCQuestion(
            id: "c3-e4",
            prompt: "The fireworks start ___ eight o'clock.",
            options: ["in", "on", "at", "for"],
            correctIndex: 2,
            explanation: "We use 'at' for clock times."
        )
    ]

    private static let chapter3Reading = ReadingPassage(
        id: "c3-r1",
        title: "Mid-Autumn Festival in Hong Kong",
        paragraphs: [
            "Mid-Autumn Festival is one of the most important festivals in Hong Kong. It usually falls in September or October. Families come together for a happy reunion and enjoy a big dinner.",
            "At night, people go outside to look at the bright full moon. Children carry colourful lanterns in many shapes, such as rabbits and fish. Some families go to Victoria Park to see the beautiful lantern displays.",
            "The most famous food of the festival is the mooncake. Mooncakes are round and sweet. Some have a salted egg yolk inside. After eating, families share tea and stories under the moonlight. The festival is a time to be thankful and to spend time with the people we love."
        ],
        questions: [
            MCQuestion(
                id: "c3-r1-q1",
                prompt: "When does Mid-Autumn Festival usually fall?",
                options: [
                    "January or February",
                    "September or October",
                    "May or June",
                    "November or December"
                ],
                correctIndex: 1,
                explanation: "The passage says it 'usually falls in September or October'."
            ),
            MCQuestion(
                id: "c3-r1-q2",
                prompt: "What do children carry at night?",
                options: ["Mooncakes", "Lanterns", "Umbrellas", "Flowers"],
                correctIndex: 1,
                explanation: "The passage says children 'carry colourful lanterns'."
            ),
            MCQuestion(
                id: "c3-r1-q3",
                prompt: "What is the most famous food of the festival?",
                options: ["Rice", "Mooncake", "Noodles", "Dumplings"],
                correctIndex: 1,
                explanation: "The passage says 'the most famous food... is the mooncake'."
            ),
            MCQuestion(
                id: "c3-r1-q4",
                prompt: "What shape are mooncakes?",
                options: ["Square", "Round", "Star-shaped", "Long"],
                correctIndex: 1,
                explanation: "The passage says mooncakes are 'round and sweet'."
            ),
            MCQuestion(
                id: "c3-r1-q5",
                prompt: "Why is the festival special for families?",
                options: [
                    "They get to stay home alone",
                    "They come together and spend time with loved ones",
                    "They buy new clothes",
                    "They travel to other countries"
                ],
                correctIndex: 1,
                explanation: "The passage says it is a time for reunion and 'spending time with the people we love'."
            )
        ]
    )

    // MARK: - Assembled textbook

    static let textbook = Textbook(
        id: "tb-p5-eng",
        title: "Primary 5 English",
        subject: "English",
        grade: "Primary 5",
        chapters: [
            Chapter(
                id: "ch-1", number: 1,
                title: "Healthy Living",
                subtitle: "Habits, routines and staying well",
                icon: "heart.fill", colorHex: "FF6B6B",
                vocabulary: chapter1Vocabulary, grammar: chapter1Grammar,
                exercises: chapter1Exercises, reading: chapter1Reading
            ),
            Chapter(
                id: "ch-2", number: 2,
                title: "Protecting Our Environment",
                subtitle: "Reduce, reuse and recycle",
                icon: "leaf.fill", colorHex: "3CB371",
                vocabulary: chapter2Vocabulary, grammar: chapter2Grammar,
                exercises: chapter2Exercises, reading: chapter2Reading
            ),
            Chapter(
                id: "ch-3", number: 3,
                title: "Festivals and Celebrations",
                subtitle: "Traditions and special days",
                icon: "sparkles", colorHex: "FFA94D",
                vocabulary: chapter3Vocabulary, grammar: chapter3Grammar,
                exercises: chapter3Exercises, reading: chapter3Reading
            )
        ]
    )

    // MARK: - Dummy homework + announcements

    static let homework: [HomeworkSession] = [
        HomeworkSession(
            id: "hw-1",
            title: "Unit 1 Reading Comprehension",
            chapterTitle: "Healthy Living",
            type: "Reading",
            assignedDate: "2026-09-08",
            dueDate: "2026-09-12",
            progress: 0.6,
            score: 80
        ),
        HomeworkSession(
            id: "hw-2",
            title: "Vocabulary Spelling Quiz",
            chapterTitle: "Protecting Our Environment",
            type: "Vocabulary",
            assignedDate: "2026-09-05",
            dueDate: "2026-09-10",
            progress: 1.0,
            score: 95
        )
    ]

    static let announcements: [Announcement] = [
        Announcement(
            id: "ann-1",
            title: "English Week is coming!",
            date: "2026-09-09",
            author: "Miss Wong",
            body: "Dear students, our school English Week will be held from 21 to 25 September. There will be spelling games, a story-telling competition and a book fair. Please prepare your favourite English book to share with your classmates."
        ),
        Announcement(
            id: "ann-2",
            title: "Reading log reminder",
            date: "2026-09-07",
            author: "Mr. Lee",
            body: "Please remember to finish your weekly reading log by Friday. Write one or two sentences about the book you read and practise reading it aloud to your family."
        )
    ]
}
