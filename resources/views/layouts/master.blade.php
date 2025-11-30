<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Winnerschool | Dashboard</title>

    <link rel="stylesheet"
        href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">

    <link rel="stylesheet" href="{{ asset('plugins/fontawesome-free/css/all.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/icheck-bootstrap/icheck-bootstrap.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/jqvmap/jqvmap.min.css') }}">
    <link rel="stylesheet" href="{{ asset('css/adminlte.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/overlayScrollbars/css/OverlayScrollbars.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/daterangepicker/daterangepicker.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/summernote/summernote-bs4.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/toastr/toastr.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/datatables-bs4/css/dataTables.bootstrap4.min.css') }}">
    <link rel="stylesheet" href="{{ asset('/plugins/datatables-responsive/css/responsive.bootstrap4.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/datatables-buttons/css/buttons.bootstrap4.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/select2/css/select2.min.css') }}">
    <link rel="stylesheet" href="{{ asset('plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css') }}">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" rel="stylesheet" />

    <!-- DataTables CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.css">
    <link rel="stylesheet" type="text/css"
        href="https://cdn.datatables.net/buttons/2.2.2/css/buttons.dataTables.min.css">

    


    <style>
        .dropdown-menu {
            z-index: 1050 !important;
        }

        /* Role Badge Styling */
        .badge {
            font-size: 0.75rem;
            padding: 0.35em 0.65em;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Navbar User Info Styling */
        .navbar-nav .nav-link {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .navbar-nav .nav-link i {
            font-size: 1rem;
        }

        /* Sidebar Menu Icons */
        .nav-sidebar .nav-icon {
            margin-right: 0.5rem;
        }

        /* Active Menu Item */
        .nav-sidebar .nav-link.active {
            background-color: #007bff !important;
            color: #fff !important;
        }

        /* Menu Open State */
        .nav-item.menu-open > .nav-link {
            background-color: rgba(255, 255, 255, 0.1);
        }

        /* Submenu Styling */
        .nav-treeview > .nav-item > .nav-link {
            padding-left: 3rem;
        }

        /* Balance Display */
        .nav-link[title="Current Balance"] {
            font-weight: 600;
            color: #28a745 !important;
        }

        /* Role Badge Colors */
        .badge-danger {
            background-color: #dc3545;
        }

        .badge-primary {
            background-color: #007bff;
        }

        .badge-warning {
            background-color: #ffc107;
            color: #212529;
        }
    </style>

    @yield('style')


</head>

<body class="hold-transition sidebar-mini layout-fixed">
    <div class="wrapper">
        <!-- Navbar -->
        <nav class="main-header navbar navbar-expand navbar-white navbar-light sticky-top">
            <!-- Left navbar links -->
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i
                            class="fas fa-bars"></i></a>
                </li>
                <li class="nav-item d-none d-sm-inline-block">
                    <a href="{{ route('admin.home') }}" class="nav-link">Home</a>
                </li>
            </ul>



            <!-- Right navbar links -->
            <ul class="navbar-nav ml-auto">
                <!-- User Role Badge -->
                <li class="nav-item">
                    <a class="nav-link" href="#">
                        @php
                            $userType = \App\Enums\UserType::from(auth()->user()->type);
                            $badgeClass = match($userType) {
                                \App\Enums\UserType::HeadTeacher => 'badge-danger',
                                \App\Enums\UserType::Student => 'badge-primary',
                                \App\Enums\UserType::SystemWallet => 'badge-warning',
                                default => 'badge-secondary'
                            };
                        @endphp
                        <span class="badge {{ $badgeClass }}">{{ $userType->label() }}</span>
                    </a>
                </li>

                <!-- User Profile -->
                <li class="nav-item">
                    <a class="nav-link"
                        href="{{ route('admin.profile_index',$id = \Illuminate\Support\Facades\Auth::id()) }}"
                        title="View Profile">
                        <i class="fas fa-user-circle"></i>
                        {{ auth()->user()->user_name }}
                    </a>
                </li>

                <!-- Balance Display -->
                <li class="nav-item">
                    <a class="nav-link" href="#" title="Current Balance">
                        <i class="fas fa-wallet"></i>
                        {{ number_format(auth()->user()->balance, 2) }} MMK
                    </a>
                </li> 

                <!-- Logout -->
                <li class="nav-item">
                    <a class="nav-link" href="#"
                        onclick="event.preventDefault(); document.getElementById('logout-form').submit();"
                        title="Logout">
                        <i class="fas fa-sign-out-alt"></i>
                        Logout
                    </a>

                    <form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
                        @csrf
                    </form>
                </li>
            </ul>
        </nav>
        <!-- /.navbar -->

        <!-- Main Sidebar Container -->
        <aside class="main-sidebar sidebar-dark-primary elevation-4">
            <!-- Brand Logo -->
             <a href="{{ route('admin.home') }}" class="brand-link">
            <img src="{{ asset('assets/img/logo/1.png') }}" alt="AdminLTE Logo"
                class="brand-image img-circle elevation-3" style="opacity: .8">
            <span class="brand-text font-weight-light">Winnerschool</span>
            </a>
            <!-- Brand Logo -->

            

            <!-- Sidebar -->
            <div class="sidebar">
                <nav class="mt-2">
                    <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu"
                        data-accordion="false">
                        @php
                            $userType = \App\Enums\UserType::from(auth()->user()->type);
                            $isStudent = $userType === \App\Enums\UserType::Student;
                        @endphp

                        @unless($isStudent)
                        <li class="nav-item">
                            <a href="{{ route('admin.home') }}"
                                class="nav-link {{ Route::currentRouteName() === 'admin.home' ? 'active' : '' }}">
                                <i class="nav-icon fas fa-tachometer-alt"></i>
                                <p>Dashboard</p>
                            </a>
                        </li>
                        @endunless

                        @if($userType === \App\Enums\UserType::HeadTeacher)
                            <li class="nav-header">Staff Management</li>
                                    <li class="nav-item">
                                <a href="{{ route('admin.teachers.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.teachers.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-chalkboard-teacher"></i>
                                    <p>Teachers</p>
                                        </a>
                            </li>

                            <li class="nav-header">Academic Management</li>
                            <li class="nav-item">
                                <a href="{{ route('admin.academic-years.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.academic-years.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-calendar-alt"></i>
                                    <p>Academic Years</p>
                                </a>
                            </li>
                                    <li class="nav-item">
                                <a href="{{ route('admin.school-classes.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.school-classes.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-school"></i>
                                    <p>Classes</p>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                <a href="{{ route('admin.subjects.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.subjects.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-book"></i>
                                    <p>Subjects</p>
                                        </a>
                            </li>
                            <li class="nav-item">
                                <a href="{{ route('admin.dictionary.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.dictionary.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-book"></i>
                                    <p>Dictionary</p>
                                        </a>
                            </li>

                            <li class="nav-item">
                                <a href="{{ route('admin.agent.withdraw') }}"
                                    class="nav-link {{ Route::currentRouteName() == 'admin.agent.withdraw' ? 'active' : '' }}">
                                    <i class="fas fa-comment-dollar"></i>
                                    <p>
                                        Withdraw Request
                                    </p>
                                </a>
                            </li>

                            <li class="nav-item">
                                <a href="{{ route('admin.agent.deposit') }}"
                                    class="nav-link {{ Route::currentRouteName() == 'admin.agent.deposit' ? 'active' : '' }}">
                                    <i class="fab fa-dochub"></i>
                                    <p>
                                        Deposit Request
                                    </p>
                                </a>
                            </li>
                        @endif

                        @if($userType === \App\Enums\UserType::Teacher)
                            <li class="nav-header">My Classroom</li>
                            <li class="nav-item">
                                <a href="{{ route('teacher.students.assign.index') }}"
                                   class="nav-link {{ request()->routeIs('teacher.students.assign.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-users"></i>
                                    <p>My Students</p>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a href="{{ route('teacher.lessons.index') }}"
                                   class="nav-link {{ request()->routeIs('teacher.lessons.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-book"></i>
                                    <p>My Lessons</p>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a href="{{ route('admin.dictionary.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.dictionary.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-book"></i>
                                    <p>Dictionary</p>
                                        </a>
                            </li>

                            <li class="nav-item">
                                <a href="{{ route('admin.banks.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.banks.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-university"></i>
                                    <p>Banks</p>
                                        </a>
                            </li>
                        @endif

                        @if($userType === \App\Enums\UserType::HeadTeacher)
                            <li class="nav-header">Finance</li>
                            <li class="nav-item">
                                <a href="{{ route('admin.banks.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.banks.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-university"></i>
                                    <p>Banks</p>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                <a href="{{ route('admin.paymentTypes.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.paymentTypes.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-credit-card"></i>
                                    <p>Payment Types</p>
                                        </a>
                            </li>

                            <li class="nav-header">Content & Promotions</li>
                                    <li class="nav-item">
                                        <a href="{{ route('admin.video-upload.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.video-upload.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-video"></i>
                                            <p>Ads Video</p>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="{{ route('admin.text.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.text.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-heading"></i>
                                            <p>Banner Text</p>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="{{ route('admin.banners.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.banners.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-image"></i>
                                    <p>Banners</p>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="{{ route('admin.adsbanners.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.adsbanners.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-ad"></i>
                                            <p>Banner Ads</p>
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a href="{{ route('admin.promotions.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.promotions.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-bullhorn"></i>
                                            <p>Promotions</p>
                                        </a>
                            </li>

                            <li class="nav-header">Communication</li>
                            <li class="nav-item">
                                <a href="{{ route('admin.contacts.index') }}"
                                   class="nav-link {{ request()->routeIs('admin.contacts.*') ? 'active' : '' }}">
                                    <i class="nav-icon fas fa-address-book"></i>
                                    <p>Contact Management</p>
                                </a>
                            </li>
                                <li class="nav-item">
                                    <a href="{{ route('admin.contact.index') }}"
                                       class="nav-link {{ request()->routeIs('admin.contact.*') ? 'active' : '' }}">
                                        <i class="nav-icon fas fa-phone"></i>
                                    <p>Student Contact</p>
                                    </a>
                                </li>
                        @endif
                    </ul>
                </nav>
                <!-- /.sidebar-menu -->
            </div>
            <!-- /.sidebar -->
        </aside>

        <div class="content-wrapper">

            @yield('content')
        </div>
        <footer class="main-footer">
            <strong>Copyright &copy; 2025 <a href="">ShweDragon</a>.</strong>
            All rights reserved.
            <div class="float-right d-none d-sm-inline-block">
                <b>Version</b> 3.2.2
            </div>
        </footer>

        <aside class="control-sidebar control-sidebar-dark">
        </aside>
    </div>

    <script src="{{ asset('plugins/jquery/jquery.min.js') }}"></script>
    <script src="{{ asset('plugins/jquery-ui/jquery-ui.min.js') }}"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
    <script>
        // $.widget.bridge('uibutton', $.ui.button)
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.1/umd/popper.min.js"></script>
    <script src="{{ asset('plugins/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('plugins/bootstrap/js/bootstrap.min.js') }}"></script>
    <script src="{{ asset('plugins/moment/moment.min.js') }}"></script>
    <script src="{{ asset('plugins/daterangepicker/daterangepicker.js') }}"></script>
    <script src="{{ asset('plugins/summernote/summernote-bs4.min.js') }}"></script>
    <script src="{{ asset('plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js') }}"></script>
    <script src="{{ asset('js/adminlte.js') }}"></script>
    <script src="{{ asset('js/dashboard.js') }}"></script>
    <script src="{{ asset('plugins/sweetalert2/sweetalert2.min.js') }}"></script>
    <script src="{{ asset('plugins/toastr/toastr.min.js') }}"></script>
    <script src="{{ asset('plugins/datatables/jquery.dataTables.min.js') }}"></script>
    <script src="{{ asset('plugins/datatables-bs4/js/dataTables.bootstrap4.min.js') }}"></script>
    <script src="{{ asset('plugins/datatables-responsive/js/dataTables.responsive.min.js') }}"></script>
    <script src="{{ asset('plugins/datatables-responsive/js/responsive.bootstrap4.min.js') }}"></script>
    <script src="{{ asset('plugins/select2/js/select2.full.min.js') }}"></script>

    <!-- DataTables JS -->
    <script type="text/javascript" src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/buttons/2.2.2/js/dataTables.buttons.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.html5.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.print.min.js"></script>

    @yield('script')
    <script>
        var errorMessage = @json(session('error'));
        var successMessage = @json(session('success'));

        @if (session()->has('success'))
            toastr.success(successMessage)
        @elseif (session()->has('error'))
            toastr.error(errorMessage)
        @endif
    </script>
    <script>
        $(function() {
            $('.select2bs4').select2({
                theme: 'bootstrap4'
            });
            $('#ponewineTable').DataTable();
            $('#slotTable').DataTable();

            $("#mytable").DataTable({
                "responsive": true,
                "lengthChange": false,
                "autoWidth": false,
                "order": true,
                "pageLength": 10,
            }).buttons().container().appendTo('#example1_wrapper .col-md-6:eq(0)');
        });
    </script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var dropdownElementList = [].slice.call(document.querySelectorAll('.dropdown-toggle'))
            var dropdownList = dropdownElementList.map(function(dropdownToggleEl) {
                return new bootstrap.Dropdown(dropdownToggleEl)
            })
        });
    </script>



</body>

</html>
