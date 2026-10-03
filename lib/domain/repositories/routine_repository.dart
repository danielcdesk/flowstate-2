import 'package:flowstate/domain/routine/routine_block.dart';

abstract interface class RoutineRepository {
  Future<List<RoutineBlock>> getActiveBlocks();

  Future<void> saveBlock(RoutineBlock block);
}
