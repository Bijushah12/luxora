import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../providers/admin_orders_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_feedback.dart';
import '../../widgets/admin/admin_section.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _statusFilter = 'All';

  List<AdminOrder> _filterOrders(List<AdminOrder> orders) {
    if (_statusFilter == 'All') {
      return orders;
    }
    return orders
        .where(
          (order) => AdminOrderStatus.normalize(order.status) == _statusFilter,
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrdersProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<AdminOrder>>(
          stream: provider.ordersStream(),
          builder: (context, snapshot) {
            final orders = snapshot.data ?? const <AdminOrder>[];
            final filteredOrders = _filterOrders(orders);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AdminFeedbackBanner(
                  error: provider.errorMessage,
                  success: provider.successMessage,
                  onClose: provider.clearMessages,
                ),
                AdminSection(
                  title: 'Orders',
                  subtitle:
                      'Review order details and update fulfillment status',
                  icon: Icons.inventory_2_outlined,
                  trailing: SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<String>(
                      initialValue: _statusFilter,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const ['All', ...AdminOrderStatus.values]
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _statusFilter = value);
                        }
                      },
                    ),
                  ),
                  child: Column(
                    children: [
                      _OrderSummaryStrip(orders: orders),
                      const SizedBox(height: 16),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(minHeight: 3)
                      else if (snapshot.hasError)
                        _InlineError(message: snapshot.error.toString())
                      else if (orders.isEmpty)
                        const SizedBox(
                          height: 340,
                          child: AdminEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'No orders yet',
                            message:
                                'Firestore orders will appear here after customers place orders.',
                          ),
                        )
                      else if (filteredOrders.isEmpty)
                        const SizedBox(
                          height: 260,
                          child: AdminEmptyState(
                            icon: Icons.filter_alt_off_outlined,
                            title: 'No orders match this filter',
                            message: 'Choose another order status.',
                          ),
                        )
                      else
                        Column(
                          children: filteredOrders
                              .map(
                                (order) => _OrderPanel(
                                  order: order,
                                  isUpdating: provider.isUpdating(order.id),
                                  onStatusChanged: (status) =>
                                      provider.updateStatus(order.id, status),
                                ),
                              )
                              .toList(growable: false),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OrderSummaryStrip extends StatelessWidget {
  final List<AdminOrder> orders;

  const _OrderSummaryStrip({required this.orders});

  @override
  Widget build(BuildContext context) {
    int countFor(String status) {
      return orders
          .where((order) => AdminOrderStatus.normalize(order.status) == status)
          .length;
    }

    return _AdminSummaryGrid(
      items: [
        _AdminSummaryItem(
          label: 'Total',
          value: orders.length.toString(),
          icon: Icons.receipt_long_outlined,
          color: AppColors.primary,
        ),
        _AdminSummaryItem(
          label: 'Pending',
          value: countFor(AdminOrderStatus.pending).toString(),
          icon: Icons.pending_actions_outlined,
          color: const Color(0xFF2563EB),
        ),
        _AdminSummaryItem(
          label: 'Packed',
          value: countFor(AdminOrderStatus.packed).toString(),
          icon: Icons.inventory_outlined,
          color: const Color(0xFF7C3AED),
        ),
        _AdminSummaryItem(
          label: 'Shipped',
          value: countFor(AdminOrderStatus.shipped).toString(),
          icon: Icons.local_shipping_outlined,
          color: AppColors.warning,
        ),
        _AdminSummaryItem(
          label: 'Delivered',
          value: countFor(AdminOrderStatus.delivered).toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _AdminSummaryGrid extends StatelessWidget {
  final List<_AdminSummaryItem> items;

  const _AdminSummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : 10,
                      ),
                      child: _AdminSummaryTile(item: item),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        }

        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 176,
              child: _AdminSummaryTile(item: items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _AdminSummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminSummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _AdminSummaryTile extends StatelessWidget {
  final _AdminSummaryItem item;

  const _AdminSummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  final AdminOrder order;
  final bool isUpdating;
  final ValueChanged<String> onStatusChanged;

  const _OrderPanel({
    required this.order,
    required this.isUpdating,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _statusColor(order.status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: _statusColor(order.status),
          ),
        ),
        title: Text(
          '#${order.id.length > 10 ? order.id.substring(0, 10) : order.id}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${order.customerDisplayName} | Rs ${order.totalAmount.toStringAsFixed(2)} | ${_formatDate(order.createdAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: SizedBox(
          width: 176,
          child: isUpdating
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                )
              : DropdownButtonFormField<String>(
                  initialValue: AdminOrderStatus.normalize(order.status),
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: AdminOrderStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null &&
                        value != AdminOrderStatus.normalize(order.status)) {
                      onStatusChanged(value);
                    }
                  },
                ),
        ),
        children: [
          _OrderTimeline(status: order.status),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final info = _OrderInfo(order: order);
              final items = _OrderItems(items: order.items);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    Expanded(child: items),
                  ],
                );
              }

              return Column(
                children: [info, const SizedBox(height: 16), items],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final String status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final currentIndex = AdminOrderStatus.values.indexOf(
      AdminOrderStatus.normalize(status),
    );

    return _DetailBox(
      title: 'Delivery Timeline',
      icon: Icons.timeline_outlined,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            Widget stepFor(MapEntry<int, String> entry) {
              final index = entry.key;
              final label = entry.value;
              final complete = index <= currentIndex;
              final color = complete ? _statusColor(label) : AppColors.border;

              final marker = Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: complete ? 0.14 : 1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color),
                ),
                child: Icon(
                  complete ? Icons.check : Icons.radio_button_unchecked,
                  color: complete ? color : AppColors.textLight,
                  size: 16,
                ),
              );
              final text = Text(
                label,
                style: TextStyle(
                  color: complete ? AppColors.textDark : AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              );

              if (!isWide) {
                return Row(children: [marker, const SizedBox(width: 10), text]);
              }

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        marker,
                        if (index != AdminOrderStatus.values.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: complete ? color : AppColors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerLeft, child: text),
                  ],
                ),
              );
            }

            final steps = AdminOrderStatus.values.asMap().entries.map(stepFor);

            if (isWide) {
              return Row(children: steps.toList(growable: false));
            }
            return Column(
              children: steps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: step,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _OrderInfo extends StatelessWidget {
  final AdminOrder order;

  const _OrderInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return _DetailBox(
      title: 'Customer',
      icon: Icons.person_outline,
      children: [
        _DetailRow(label: 'Name', value: order.customerDisplayName),
        _DetailRow(
          label: 'Email',
          value: order.userEmail.isEmpty ? 'Not provided' : order.userEmail,
        ),
        _DetailRow(
          label: 'Phone',
          value: order.userPhone.isEmpty ? 'Not provided' : order.userPhone,
        ),
        const Divider(height: 24),
        _DetailRow(label: 'Address', value: order.address.singleLine),
      ],
    );
  }
}

class _OrderItems extends StatelessWidget {
  final List<AdminOrderItem> items;

  const _OrderItems({required this.items});

  @override
  Widget build(BuildContext context) {
    return _DetailBox(
      title: 'Products',
      icon: Icons.watch_outlined,
      children: items.isEmpty
          ? const [
              Text(
                'No product list stored on this order.',
                style: TextStyle(color: AppColors.textLight),
              ),
            ]
          : items.map((item) => _OrderItemTile(item: item)).toList(),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final AdminOrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 52,
              height: 52,
              color: AppColors.surface,
              child: item.imageUrl.trim().isEmpty
                  ? const Icon(Icons.watch_outlined, color: AppColors.textLight)
                  : Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.watch_outlined,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_itemMeta(item)} | Qty ${item.quantity} | Rs ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs ${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailBox({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (AdminOrderStatus.normalize(status)) {
    case AdminOrderStatus.packed:
      return const Color(0xFF7C3AED);
    case AdminOrderStatus.shipped:
      return AppColors.warning;
    case AdminOrderStatus.delivered:
      return AppColors.success;
    default:
      return const Color(0xFF2563EB);
  }
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Date pending';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _itemMeta(AdminOrderItem item) {
  final parts = [
    item.brand,
    item.category,
  ].where((part) => part.trim().isNotEmpty).toList(growable: false);
  return parts.isEmpty ? 'Watch' : parts.join(' | ');
}
