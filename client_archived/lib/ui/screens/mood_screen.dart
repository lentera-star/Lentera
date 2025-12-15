import 'package:flutter/material.dart';

class MoodScreen extends StatefulWidget {
	const MoodScreen({super.key});

	@override
	State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
	final TextEditingController _journalController = TextEditingController();
	int _selectedMoodIndex = -1;

	@override
	void dispose() {
		_journalController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final date = _formatDate(DateTime.now());
		final moods = _moods;

		return Scaffold(
			backgroundColor: const Color(0xFFF4F8FF),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							_Header(date: date),
							const SizedBox(height: 16),
							_CardContainer(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const Text(
											'Bagaimana Perasaanmu\nHari Ini?',
											style: TextStyle(
												fontSize: 18,
												fontWeight: FontWeight.w700,
											),
										),
										const SizedBox(height: 16),
										Wrap(
											spacing: 12,
											runSpacing: 12,
											children: List.generate(moods.length, (index) {
												final mood = moods[index];
												final isSelected = _selectedMoodIndex == index;
												return _MoodTile(
													emoji: mood.emoji,
													label: mood.label,
													isSelected: isSelected,
													onTap: () => setState(() => _selectedMoodIndex = index),
												);
											}),
										),
									],
								),
							),
							const SizedBox(height: 16),
							_CardContainer(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: const [
												Icon(Icons.menu_book_rounded, color: Color(0xFF3F63B8)),
												SizedBox(width: 8),
												Text(
													'Tulis Diary Hari Ini',
													style: TextStyle(
														fontSize: 16,
														fontWeight: FontWeight.w700,
													),
												),
											],
										),
										const SizedBox(height: 14),
										_JournalBox(controller: _journalController),
										const SizedBox(height: 8),
										Align(
											alignment: Alignment.centerRight,
											child: Text(
												'${_journalController.text.length} karakter',
												style: TextStyle(
													fontSize: 12,
													color: Colors.grey.shade600,
												),
											),
										),
										const SizedBox(height: 8),
										SizedBox(
											width: double.infinity,
											child: FilledButton(
												onPressed: _onSubmit,
												child: const Text('Simpan'),
											),
										),
									],
								),
							),
						],
					),
				),
			),
		);
	}

	void _onSubmit() {
		// Placeholder handler; will be wired to backend later.
		final moodLabel = _selectedMoodIndex >= 0 ? _moods[_selectedMoodIndex].label : 'Belum dipilih';
		final journalText = _journalController.text.trim();
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text('Mood: $moodLabel\nCatatan: ${journalText.isEmpty ? 'Kosong' : journalText}')),
		);
	}
}

class _Header extends StatelessWidget {
	const _Header({required this.date});

	final String date;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				const SizedBox(height: 4),
				const Text(
					'Daily Mood & Journal',
					style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
				),
				const SizedBox(height: 4),
				Text(
					date,
					style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
				),
			],
		);
	}
}

class _CardContainer extends StatelessWidget {
	const _CardContainer({required this.child});

	final Widget child;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(18),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.05),
						blurRadius: 12,
						offset: const Offset(0, 6),
					),
				],
			),
			child: child,
		);
	}
}

class _MoodTile extends StatelessWidget {
	const _MoodTile({
		required this.emoji,
		required this.label,
		required this.isSelected,
		required this.onTap,
	});

	final String emoji;
	final String label;
	final bool isSelected;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 150),
				padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
				width: 110,
				decoration: BoxDecoration(
					color: isSelected ? const Color(0xFFE9F2FF) : Colors.white,
					borderRadius: BorderRadius.circular(12),
					border: Border.all(
						color: isSelected ? const Color(0xFF3F63B8) : Colors.grey.shade300,
						width: 1.1,
					),
				),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text(
							emoji,
							style: const TextStyle(fontSize: 28),
						),
						const SizedBox(height: 8),
						Text(
							label,
							textAlign: TextAlign.center,
							style: TextStyle(
								fontSize: 12,
								fontWeight: FontWeight.w600,
								color: Colors.grey.shade800,
							),
						),
					],
				),
			),
		);
	}
}

class _JournalBox extends StatelessWidget {
	const _JournalBox({required this.controller});

	final TextEditingController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: const Color(0xFFF1F5FB),
				borderRadius: BorderRadius.circular(12),
			),
			child: TextField(
				controller: controller,
				minLines: 4,
				maxLines: 6,
				decoration: const InputDecoration(
					border: InputBorder.none,
					hintText:
							'Ceritakan hari ini... Apa yang membuatmu bahagia? Apa yang membuatmu khawatir? Apa yang kamu syukuri?',
				),
			),
		);
	}
}

class _MoodData {
	const _MoodData({required this.emoji, required this.label});
	final String emoji;
	final String label;
}

String _formatDate(DateTime date) {
	const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
	const months = [
		'Januari',
		'Februari',
		'Maret',
		'April',
		'Mei',
		'Juni',
		'Juli',
		'Agustus',
		'September',
		'Oktober',
		'November',
		'Desember'
	];
	final dayName = days[date.weekday % 7];
	final monthName = months[date.month - 1];
	return '$dayName, ${date.day} $monthName ${date.year}';
}

const List<_MoodData> _moods = [
	_MoodData(emoji: '😄', label: 'Sangat Bahagia'),
	_MoodData(emoji: '🙂', label: 'Bahagia'),
	_MoodData(emoji: '😐', label: 'Biasa Saja'),
	_MoodData(emoji: '😟', label: 'Sedih'),
	_MoodData(emoji: '😠', label: 'Marah'),
];
