@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">Edit Question</h1>
            <p class="mb-0 text-muted">{{ $exam->title }} ({{ $exam->code }})</p>
        </div>
        <a href="{{ route('admin.exams.questions.index', $exam) }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.exams.questions.update', [$exam, $question]) }}" method="POST" id="questionForm">
                    @csrf
                    @method('PUT')
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="order">Question Order <span class="text-danger">*</span></label>
                                <input type="number" name="order" id="order" class="form-control" 
                                       value="{{ old('order', $question->order) }}" min="1" required>
                                @error('order')
                                    <div class="text-danger">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="marks">Marks <span class="text-danger">*</span></label>
                                <input type="number" name="marks" id="marks" class="form-control" 
                                       value="{{ old('marks', $question->marks) }}" step="0.1" min="0.1" max="100" required>
                                @error('marks')
                                    <div class="text-danger">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="type">Question Type <span class="text-danger">*</span></label>
                        <select name="type" id="type" class="form-control" required>
                            <option value="multiple_choice" {{ old('type', $question->type) == 'multiple_choice' ? 'selected' : '' }}>Multiple Choice</option>
                            <option value="true_false" {{ old('type', $question->type) == 'true_false' ? 'selected' : '' }}>True/False</option>
                            <option value="short_answer" {{ old('type', $question->type) == 'short_answer' ? 'selected' : '' }}>Short Answer</option>
                        </select>
                        @error('type')
                            <div class="text-danger">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="question_text">Question Text <span class="text-danger">*</span></label>
                        <textarea name="question_text" id="question_text" class="form-control" rows="3" required>{{ old('question_text', $question->question_text) }}</textarea>
                        @error('question_text')
                            <div class="text-danger">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="question_description">Question Description (with Math Support)</label>
                        <textarea name="question_description" id="question_description" class="form-control">{{ old('question_description', $question->question_description) }}</textarea>
                        <small class="form-text text-muted">
                            Use the toolbar to format text. For math equations, use LaTeX syntax.
                        </small>
                        @error('question_description')
                            <div class="text-danger">{{ $message }}</div>
                        @enderror
                    </div>

                    <!-- Options Section (for Multiple Choice and True/False) -->
                    <div id="optionsSection" style="display: none;">
                        <div class="form-group">
                            <label>Options <span class="text-danger">*</span></label>
                            <div id="optionsContainer">
                                <!-- Options will be dynamically added here -->
                            </div>
                            <button type="button" class="btn btn-sm btn-secondary mt-2" id="addOptionBtn">
                                <i class="fas fa-plus"></i> Add Option
                            </button>
                            @error('options')
                                <div class="text-danger">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <!-- Short Answer Section -->
                    <div id="shortAnswerSection" style="display: none;">
                        <div class="form-group">
                            <label for="correct_answer">Correct Answer <span class="text-danger">*</span></label>
                            <input type="text" name="correct_answer" id="correct_answer" class="form-control" 
                                   value="{{ old('correct_answer', $question->correct_answer) }}">
                            @error('correct_answer')
                                <div class="text-danger">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="d-flex justify-content-end mt-4">
                        <a href="{{ route('admin.exams.questions.index', $exam) }}" class="btn btn-secondary mr-2">Cancel</a>
                        <button type="submit" class="btn btn-primary">Update Question</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

@section('script')
<!-- MathJax for math rendering -->
<script src="{{ asset('js/polyfill.min.js') }}"></script>
<script src="{{ asset('js/mathjax.js') }}"></script>
<script>
    window.MathJax = {
        tex: {
            inlineMath: [['\\(', '\\)']],
            displayMath: [['\\[', '\\]']],
            processEscapes: true,
            processEnvironments: true
        },
        options: {
            ignoreHtmlClass: 'tex2jax_ignore',
            processHtmlClass: 'tex2jax_process'
        }
    };
</script>

<script>
    $(function () {
        // Initialize Summernote for question description
        $('#question_description').summernote({
            height: 200,
            toolbar: [
                ['style', ['style']],
                ['font', ['bold', 'italic', 'underline', 'clear']],
                ['para', ['ul', 'ol', 'paragraph']],
                ['view', ['fullscreen', 'codeview']]
            ]
        });

        let optionCounter = 0;
        const existingOptions = @json($question->options->map(function($opt) {
            return [
                'text' => $opt->option_text,
                'is_correct' => $opt->is_correct,
                'order' => $opt->order
            ];
        }));

        // Function to add option
        function addOption(optionText = '', isCorrect = false, order = null) {
            const orderValue = order !== null ? order : optionCounter + 1;
            const optionHtml = `
                <div class="option-item card mb-2" data-option-index="${optionCounter}">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-1">
                                <label>Order</label>
                                <input type="number" name="options[${optionCounter}][order]" 
                                       class="form-control option-order" value="${orderValue}" min="1" required>
                            </div>
                            <div class="col-md-8">
                                <label>Option Text</label>
                                <input type="text" name="options[${optionCounter}][option_text]" 
                                       class="form-control" value="${optionText}" required>
                            </div>
                            <div class="col-md-2">
                                <label>Correct?</label>
                                <div class="form-check mt-2">
                                    <input type="checkbox" name="options[${optionCounter}][is_correct]" 
                                           value="1" class="form-check-input" ${isCorrect ? 'checked' : ''}>
                                    <label class="form-check-label">Yes</label>
                                </div>
                            </div>
                            <div class="col-md-1">
                                <label>&nbsp;</label>
                                <button type="button" class="btn btn-sm btn-danger btn-block remove-option">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            $('#optionsContainer').append(optionHtml);
            optionCounter++;
        }

        // Handle question type change
        function handleTypeChange() {
            const type = $('#type').val();
            if (type === 'multiple_choice' || type === 'true_false') {
                $('#optionsSection').show();
                $('#shortAnswerSection').hide();
                $('#correct_answer').removeAttr('required');
                
                // Clear and reset options
                $('#optionsContainer').empty();
                optionCounter = 0;
                
                if (type === 'true_false') {
                    // Load existing options or default
                    if (existingOptions.length > 0) {
                        existingOptions.forEach(function(opt) {
                            addOption(opt.text, opt.is_correct, opt.order);
                        });
                    } else {
                        addOption('True', false, 1);
                        addOption('False', false, 2);
                    }
                    $('#addOptionBtn').hide();
                } else {
                    // Load existing options or default
                    if (existingOptions.length > 0) {
                        existingOptions.forEach(function(opt) {
                            addOption(opt.text, opt.is_correct, opt.order);
                        });
                    } else {
                        addOption('', false, 1);
                        addOption('', false, 2);
                    }
                    $('#addOptionBtn').show();
                }
            } else if (type === 'short_answer') {
                $('#optionsSection').hide();
                $('#shortAnswerSection').show();
                $('#correct_answer').attr('required', 'required');
            }
        }

        // Trigger on load
        handleTypeChange();

        // Handle question type change
        $('#type').on('change', handleTypeChange);

        // Add option button
        $('#addOptionBtn').on('click', function() {
            addOption();
        });

        // Remove option
        $(document).on('click', '.remove-option', function() {
            $(this).closest('.option-item').remove();
        });

        // Convert checkbox to hidden input for form submission
        $('#questionForm').on('submit', function() {
            $('input[type="checkbox"][name*="[is_correct]"]').each(function() {
                if (!$(this).is(':checked')) {
                    $(this).after('<input type="hidden" name="' + $(this).attr('name') + '" value="0">');
                }
            });
        });
    });
</script>
@endsection

