@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Create Exam</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.exams.store') }}" method="POST">
                    @include('admin.exams._form', ['submitLabel' => 'Create', 'exam' => null])
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

@section('script')
<!-- MathJax for math rendering -->
    <!-- <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
    <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script> -->
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
        var editor = $('#description');
        if (editor.length) {
            editor.summernote({
                height: 300,
                toolbar: [
                    ['style', ['style']],
                    ['font', ['bold', 'italic', 'underline', 'clear', 'strikethrough', 'superscript', 'subscript']],
                    ['fontname', ['fontname']],
                    ['fontsize', ['fontsize']],
                    ['color', ['color']],
                    ['para', ['ul', 'ol', 'paragraph']],
                    ['table', ['table']],
                    ['insert', ['link', 'picture', 'video', 'math']],
                    ['view', ['fullscreen', 'codeview', 'help']]
                ],
                callbacks: {
                    onInit: function() {
                        // Add custom math button to toolbar
                        var mathButton = '<button type="button" class="btn btn-sm btn-default" data-toggle="modal" data-target="#mathModal" title="Insert Math Equation" style="margin-left: 5px;"><i class="fa fa-calculator"></i> Math</button>';
                        $('.note-toolbar .note-insert').after('<div class="note-btn-group btn-group">' + mathButton + '</div>');
                    },
                    onChange: function(contents, $editable) {
                        // Re-render MathJax when content changes
                        if (window.MathJax && window.MathJax.typesetPromise) {
                            setTimeout(function() {
                                window.MathJax.typesetPromise([editor[0]]).catch(function (err) {
                                    console.log('MathJax rendering error:', err);
                                });
                            }, 200);
                        }
                    }
                }
            });
        }
    });

    // Function to insert math equation
    function insertMathEquation(latex) {
        var mathText = '\\[' + latex + '\\]';
        $('#description').summernote('insertText', mathText);
        $('#mathModal').modal('hide');
        $('#mathInput').val('');
        
        // Trigger MathJax rendering
        if (window.MathJax && window.MathJax.typesetPromise) {
            setTimeout(function() {
                window.MathJax.typesetPromise([$('#description')[0]]).catch(function (err) {
                    console.log('MathJax rendering error:', err);
                });
            }, 100);
        }
    }
</script>

<!-- Math Equation Modal -->
<div class="modal fade" id="mathModal" tabindex="-1" role="dialog" aria-labelledby="mathModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mathModalLabel">Insert Math Equation</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label for="mathInput">LaTeX Equation:</label>
                    <input type="text" class="form-control" id="mathInput" placeholder="e.g., x^2 + y^2 = z^2 or \\frac{a}{b}">
                    <small class="form-text text-muted">
                        Enter LaTeX math syntax. Examples:
                        <ul class="mt-2 mb-0">
                            <li><code>x^2 + y^2 = z^2</code> - Power</li>
                            <li><code>\\frac{a}{b}</code> - Fraction</li>
                            <li><code>\\sqrt{x}</code> - Square root</li>
                            <li><code>\\sum_{i=1}^{n}</code> - Summation</li>
                            <li><code>\\int_{a}^{b}</code> - Integral</li>
                        </ul>
                    </small>
                </div>
                <div id="mathPreview" class="border p-3 mb-3" style="min-height: 60px; text-align: center;">
                    <span class="text-muted">Preview will appear here</span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="insertMathEquation($('#mathInput').val())">Insert</button>
            </div>
        </div>
    </div>
</div>

<script>
    // Live preview of math equation
    $('#mathInput').on('input', function() {
        var latex = $(this).val();
        if (latex) {
            $('#mathPreview').html('\\[' + latex + '\\]');
            if (window.MathJax && window.MathJax.typesetPromise) {
                window.MathJax.typesetPromise([$('#mathPreview')[0]]).catch(function (err) {
                    console.log('MathJax preview error:', err);
                });
            }
        } else {
            $('#mathPreview').html('<span class="text-muted">Preview will appear here</span>');
        }
    });
</script>
@endsection

