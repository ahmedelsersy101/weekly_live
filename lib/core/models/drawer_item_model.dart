class DrawerItemModel {
  const DrawerItemModel({required this.title, required this.image, this.onTap});
  final void Function()? onTap;
  final String title;
  final String image;
}
