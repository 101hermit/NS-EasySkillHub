/**
 * 服务接口层：对外部世界的一切依赖，都以接口形式暴露给业务层。
 *
 * <p><b>为什么这里没有 {@code SkillRepository}</b>：在 SSM 架构里，MyBatis 的
 * {@code @Mapper} 接口本身就是"持久化的抽象"—— 它没有实现类、没有 SQL 泄漏到业务层、
 * 换数据库只改 SQL 不改签名。再加一层 {@code RepositoryPort} 只会得到
 * "接口转调接口"的空壳。因此 {@code port} 只承载**真正会换实现**的依赖：
 * <ul>
 *   <li>{@link org.skillhub.port.LibraryPort} —— 从磁盘/资源读 Skill 库（未来可能改成 HTTP 远端库）</li>
 *   <li>{@link org.skillhub.port.PackagePort} —— 打包（ZIP / TAR / 未来 OCI）</li>
 *   <li>{@link org.skillhub.port.ClockPort} / {@link org.skillhub.port.IdPort} —— 可测性</li>
 * </ul>
 */
package org.skillhub.port;
